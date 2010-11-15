/*global $, document, navigator, window, twttr*/

"use strict";

var Murlsh = function (config, $, navigator, window, twtter) {

    var my = {},
        hrefRes = {
            imageshack :
                /^http:\/\/img\d+\.imageshack\.us\/img\d+\/\d+\/\w+\.(?:jpe?g|gif|png)$/i,
            imgur :
                /^http:\/\/(?:i\.)?imgur\.com\/[a-z\d]+\.(?:jpe?g|gif|png)$/i,
            s3 :
                /^http:\/\/static\.mmb\.s3\.amazonaws\.com\/[\w\-]+\.(jpe?g|gif|pdf|png)$/i,
            twitter :
                /^https?:\/\/twitter\.com\/\w+\/status(?:es)?\/\d+$/i,
            vimeo :
                /^http:\/\/(?:www\.)?vimeo\.com\/(\d+)$/i,
            youtube :
                /^http:\/\/(?:(?:www|uk)\.)?youtube\.com\/watch\?v=([\w\-]+)(?:&|$)/i
        };

    function setupClickHandler(jQueryObject, dataKey, dataValue, handler) {
        if (!my.isIphone()) {
            jQueryObject.data(dataKey, dataValue).click(handler).addClass(
                'clickable');
        }
    }

    function autoLink(s) {
        // turn urls into links
        var result = s.replace(
            /https?:\/\/(?:[0-9a-z](?:[0-9a-z\-]{0,61}[0-9a-z])?\.)+[a-z]+\/[0-9a-z$_.+!*'(),\/?#\-]*/gi,
            '<a href="$&">$&</a>');

        return result;
    }

    function makeIframe(src) {
        return $('<iframe />').attr({
            src: src,
            width: 640,
            height: 385,
            frameborder: 0
        });
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
            },
            animateOpen : { width : 'show' },
            animateClose : { width : 'hide' }
        });
    }

    function imgClick(event) {
        closerAdd(img($(event.target).data('href')));
    }

    function vimeoClick(event) {
        var iframe = makeIframe(
            'http://player.vimeo.com/video/' + $(event.target).data('id'));

        closerAdd(iframe);
    }

    function youtubeClick(event) {
        var iframe = makeIframe(
            'http://www.youtube.com/embed/' + $(event.target).data('id')).attr({
            'class': 'youtube-player',
            type: 'text/html'
        });

        closerAdd(iframe);
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
                .append($('<span />').append(autoLink(comment.comment))
                    .addClass('comment-comment'))
                .appendTo(ul);
        }
    };

    my.addExtra = function () {
        var thisA = $(this),
            href = thisA.attr('href'),
            match = {},
            tweetMatch,
            tweetLink,
            formattedTweet;

        $.each(hrefRes, function (x, re) {
            return !(match[x] = re.exec(href));
        });

        if (match.imageshack || match.imgur) {
            setupClickHandler(thisA.siblings('img'), 'href', href, imgClick);
        } else if (match.s3) {
            if (!(match.s3[1].match(/^pdf$/i))) {
                setupClickHandler(thisA.siblings('img'), 'href', href,
                    imgClick);
            }
        } else if (match.twitter) {
            thisA.siblings('img').addClass('twitter');
            tweetMatch = /^(@[0-9a-z_]+?): (.+)$/i.exec(thisA.text());
            if (tweetMatch) {
                tweetLink = $('<a />', {
                    href : href,
                    text : tweetMatch[1]
                });

                formattedTweet = $('<span />').addClass('tweet').append(
                    tweetLink).append(': ').append(
                    twttr.txt.autoLink(tweetMatch[2]));

                thisA.replaceWith(formattedTweet);
            }
        } else if (match.vimeo) {
            setupClickHandler(thisA.siblings('img'), 'id', match.vimeo[1],
                vimeoClick);
        } else if (match.youtube) {
            setupClickHandler(thisA.siblings('img'), 'id', match.youtube[1],
                youtubeClick);
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
        var murlsh = new Murlsh(config, $, navigator, window, twttr),
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
        // experimental comment support, to enable uncomment and edit
        // comments.json
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
