/*global $, document, navigator, window*/

"use strict";

var Murlsh = function (config, $, navigator, window) {
    function compileRegexMap(regexMap) {
        var result = {};
        $.each(regexMap, function (reStr) {
            result[reStr] = new RegExp('^' + reStr + '$', 'i'); 
        });

        return result;
    }

    var my = {},
        hrefRes = {
            flickr :
                /^http:\/\/(?:www\.)?flickr\.com\/photos\/[@\w\-]+?\/([\d]+)/i,
            imageshack :
                /^(http:\/\/img\d+\.imageshack\.us\/img\d+\/\d+\/\w+\.)(jpe?g|gif|png)$/i,
            imgur :
                /^(http:\/\/(?:i\.)?imgur\.com\/[a-z\d]+)(\.(?:jpe?g|gif|png))$/i,
            mp3 :
                /\.mp3$/i,
            s3 :
                /^(http:\/\/static\.mmb\.s3\.amazonaws\.com\/[\w\-]+\.)(jpe?g|gif|pdf|png)$/i,
            twitter :
                /^https?:\/\/twitter\.com\/\w+\/status(?:es)?\/(\d+)$/i,
            vimeo :
                /^http:\/\/(?:www\.)?vimeo\.com\/(\d+)$/i,
            youtube :
                /^http:\/\/(?:(?:www|uk)\.)?youtube\.com\/watch\?v=([\w\-]+)(?:&|$)/i
        },
        thumbLocatorsCompiled = compileRegexMap(config.thumb_locators);

    function autoLink(s) {
        // turn urls into links
        var result = s.replace(
            /https?:\/\/(?:[0-9a-z](?:[0-9a-z\-]{0,61}[0-9a-z])?\.)+[a-z]+\/[0-9a-z$_.+!*'(),\/?#\-]*/gi,
            '<a href="$&">$&</a>');

        return result;
    }

    function escapeXml(s) {
        return s.replace(/&/g, '&amp;');
    }

    function img(src, text) {
        text = text || '';
        return $('<img />', {
            src : src,
            alt : text,
            title : text
        });
    }

    function makeFit(e, maxWidth, maxHeight) {
        var height = e.height(),
            scale,
            width = e.width();

        if (width > maxWidth || height > maxHeight) {
            scale = Math.min(maxWidth / width, maxHeight / height);
            e.width(Math.round(width * scale));
            e.height(Math.round(height * scale));
        }
    }

    function objectTag(data, height, width, params) {
        // this does not use jQuery to build tags because building object
        // tags is broken in IE
        var result = '<object data="' + escapeXml(data) +
            '" height="' + height +
            '" type="application/x-shockwave-flash" width="' + width + '">';

        $.each(params, function (i, v) {
            result += '<param name="' + v.name + '" value="' +
                escapeXml(v.value) + '" />';
        });

        result += '</object>';

        return result;
    }

    function closerAdd(x, header) {
        var html = (typeof x === 'object') ? $('<div />').append(x).html() : x;

        $.jGrowl(html, {
            closeTemplate : 'X',
            glue : 'before',
            header : header,
            sticky : true,
            beforeOpen : function (e) {
                e.find('.message img').load(function () {
                    makeFit($(this), Math.round($(window).width() / 2),
                        Math.round($(window).height() - 100));
                });
            }
        });
    }

    function flickrClick() {
        closerAdd(img($(this).data('zoom')));
    }

    function flickrThumb(d) {
        var base,
            owner,
            photo = d.photo,
            zoom;

        if (d.stat === 'ok') {
            base = 'http://farm' + photo.farm + '.static.flickr.com/' +
                photo.server + '/' + photo.id + '_';
            zoom = base + photo.secret + '_m.jpg';

            if (photo.originalsecret) {
                zoom = base + photo.originalsecret + '_o.' +
                    photo.originalformat;
            }

            owner = photo.owner;
            return img(base + photo.secret + '_s.jpg', photo.title._content +
                (owner && owner.username ? ' by ' + owner.username : '')
                ).addClass('thumb flickr').data('zoom', zoom);
        }
    }

    function imgClick() {
        closerAdd(img($(this).data('href')));
    }

    function imgThumb() {
        var i,
            lastIndex,
            urlParts = [];

        for (i = 0; i < arguments.length; i += 1) {
            urlParts.push(arguments[i]);
        }

        lastIndex = urlParts.length - 1;

        // if pdf the thumbnail will be .png
        if (urlParts[lastIndex].match(/^pdf$/i)) {
            urlParts.splice(lastIndex, 1, 'png');
        }

        return img(urlParts.join('')).addClass('thumb');
    }

    function thumbInsert(img, clickFunction, a) {
        if (img) {
            if (my.isIphone()) {
                a.prepend(img);
            } else {
                if (clickFunction) {
                    img.click(clickFunction);
                }
                a.before(img);
            }
        }
    }

    function twitterAddLinks(s) {
        // turn urls into links and Twitter usernames into links to Twitter
        var result = autoLink(s);

        result = result.replace(
            /(^|[\s,(])@([0-9a-z_]+)($|[\s,.)])/gi,
            '$1<a href="http://twitter.com/$2">@$2</a>$3');

        return result;
    }

    function twitterThumb(d) {
        return img(d.user.profile_image_url).addClass('thumb twitter');
    }

    function vimeoClick() {
        closerAdd($(this).data('embedHtml'));
    }

    function vimeoThumb(d) {
        return img(d.thumbnail_medium, d.title).addClass('thumb vimeo');
    }

    function youtubeClick() {
        var movie = 'http://www.youtube.com/v/' + $(this).data('id') + '?' +
            $.param({
                fs : 1,
                hd : 1,
                hl : 'en',
                iv_load_policy : 3,
                showinfo : 0,
                showsearch : 0
            });

        closerAdd(objectTag(movie, 505, 640, [{
            name : 'movie',
            value : movie
        }]));
    }

    function youtubeThumb(id) {
        return img('http://img.youtube.com/vi/' + id + '/default.jpg',
            'click to watch').addClass('thumb youtube').data('id', id);
    }

    my.addComments = function (link, comments) {
        var avatar,
            comment,
            commentElement,
            i,
            ul = $('<ul />').addClass('comments').appendTo(link.parent());

        for (i = 0; i < comments.length; i += 1) {
            comment = comments[i];
            commentElement = $('<li />');
            if (comment.authorAvatar.length > 0) {
                avatar = img(comment.authorAvatar).appendTo(commentElement);
                if (comment.authorUrl.length > 0) {
                    avatar.wrapAll($('<a />').attr('href', comment.authorUrl));
                }
                commentElement.append(' ');
            }
            commentElement
                .append($('<span />').append(comment.authorName).addClass(
                    'comment-name'))
                .append(' : ')
                .append($('<span />').append(autoLink(comment.comment)).
                    addClass('comment-comment'))
                .appendTo(ul);
        }
    };

    my.addExtra = function () {
        var thisA = $(this),
            href = thisA.attr('href'),
            match = {},
            swf = 'swf/player_mp3_mini.swf',
            thumb;

        $.each(hrefRes, function (x, re) {
            return !(match[x] = re.exec(href));
        });

        if (match.flickr) {
            $.ajax({
                // url : 'http://api.flickr.com/services/rest/',
                url : 'flickr',
                data : {
                    format : 'json',
                    method : 'flickr.photos.getinfo',
                    photo_id : match.flickr[1]
                },
                dataType : 'jsonp',
                jsonp : 'jsoncallback',
                success : function (d) {
                    thumbInsert(flickrThumb(d), flickrClick, $(this));
                },
                context : thisA,
                jsonpCallback : 'flickrCallback' + match.flickr[1]
            });
        } else if (match.imageshack) {
            thumbInsert(imgThumb(match.imageshack[1], 'th.',
                match.imageshack[2]).data('href', match.imageshack[0]),
                    imgClick, thisA.html('imageshack.us'));
        } else if (match.imgur) {
            thumbInsert(imgThumb(match.imgur[1], 's', match.imgur[2]).data(
                'href', match.imgur[0]), imgClick, thisA.html('imgur.com'));
        } else if (match.mp3) {
            thisA.before(objectTag(swf, 20, 200, [
                { name : 'bgcolor', value : '#000000' },
                { name : 'FlashVars', value : 'mp3=' + href },
                { name : 'movie', value : swf }
            ]));
        } else if (match.s3) {
            thumb = imgThumb(match.s3[1], 'th.', match.s3[2]);

            if (match.s3[2].match(/^pdf$/i)) {
                thisA.before(thumb).html('pdf');
            } else {
                if (my.isIphone()) {
                    thisA.html(thumb);
                } else {
                    thisA.html('link');
                    thisA.before(thumb.data('href', match.s3[0]).click(
                        imgClick));
                }
            }
        } else if (match.twitter) {
            $.ajax({
                // url : 'http://api.twitter.com/1/statuses/show/' +
                url : '/twitter/1/statuses/show/' +
                    match.twitter[1] + '.json',
                dataType : 'jsonp',
                success : function (d) {
                    var nameLink = $('<a />', {
                        href: 'http://twitter.com/' + d.user.screen_name +
                            '/status/' + d.id,
                        text: '@' + d.user.screen_name
                    }),
                        tweet = $('<span />').addClass('tweet').append(
                            nameLink).append(': ').append(twitterAddLinks(
                            d.text));

                    thumbInsert(twitterThumb(d), null, nameLink);

                    $(this).replaceWith(tweet);
                },
                context : thisA,
                jsonpCallback : 'twitterCallback' + match.twitter[1]
            });
        } else if (match.vimeo) {
            $.ajax({
                url : 'http://vimeo.com/api/v2/video/' + match.vimeo[1] +
                    '.json',
                dataType : 'jsonp',
                success : function (d) {
                    var video = d[0],
                        movie = 'http://vimeo.com/moogaloop.swf?clip_id=' +
                        video.id;

                    thumbInsert(vimeoThumb(video).data('embedHtml',
                        objectTag(movie, video.height, video.width, [
                            { name : 'movie', value : movie }
                        ])), vimeoClick, $(this));
                },
                context : thisA,
                jsonpCallback : 'vimeoCallback' + match.vimeo[1]
            });
        } else if (match.youtube) {
            thumbInsert(youtubeThumb(match.youtube[1]), youtubeClick, thisA);
        } else {
            $.each(config.thumb_locators, function (reStr) {
                var re = thumbLocatorsCompiled[reStr];
                if (href.match(re)) {
                    thumbInsert(img(href.replace(re,
                        config.thumb_locators[reStr])).addClass(
                        'thumb locator'), null, thisA);
                    return false;
                }
            });
        }
    };

    my.formatLi = function (d) {
        var iconSize = 32,
            li = $('<li />').append($('<a />', {
                href : d.url,
                text : d.title
            }));

        if (d.name) {
            li.prepend($('<div />', { text : d.name }).addClass('name'));
        }

        if (d.email) {
            li.prepend($('<div />').addClass('icon').append(
                img('http://www.gravatar.com/avatar/' + d.email + '?s=' +
                    iconSize, d.name).attr({
                    width : iconSize,
                    height : iconSize
                })));
        }

        return li;
    };

    my.iphoneInit = function () {
        window.onorientationchange = function () {
            var width = 450;
            if (window.orientation === 0 || window.orientation === 180) {
                width = 290;
            }
            $('#urls').width(width);
        };

        window.onorientationchange();

        $('a.feed').replaceWith($('<a />', {
            href : '#bottom',
            text : 'bottom'
        }));
    };

    my.isIphone = function () {
        return navigator.userAgent.match(/i(phone|pod)/i);
    };

    return my;
};

$(document).ready(function () {
    $.getJSON('config', function (config) {
        var murlsh = new Murlsh(config, $, navigator, window),
            urls;

        if (murlsh.isIphone()) {
            murlsh.iphoneInit();
        }

        $('#submit').click(function () {
            $.post('url', {
                url : $('#url').val(),
                via : $('#via').val(),
                auth : $('#auth').val()
            }, function (d) {
                $.each(d, function (i, v) {
                    var li = murlsh.formatLi(v);
                    $('#urls > li:first').after(li);
                    $(li).children('a:first').each(murlsh.addExtra);
                });
                $('#url').val('');
                $('#via').val('');
            }, 'json');
        });

        urls = $('a.m');

        urls.each(murlsh.addExtra);

        /*
        // experimental comment support, to enable uncomment and edit comments.json
        $.getJSON('/js/comments.json', function (data) {
            urls.each(function () {
                var href = $(this).attr('href');
                if (href in data) {
                    murlsh.addComments($(this), data[href]);
                }
            });
        });
        */
    });
});
