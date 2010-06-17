/*global $, window*/

"use strict";

var Murlsh = {};

Murlsh.img = function(src, text) {
    text = text || '';
    return $('<img />', {
        src : src,
        alt : text,
        title : text
    });
};

Murlsh.makeFit = function(e, maxWidth, maxHeight) {
    var height = e.height();
    var scale;
    var width = e.width();

    if (width > maxWidth || height > maxHeight) {
        scale = Math.min(maxWidth / width, maxHeight / height);
        e.width(Math.round(width * scale));
        e.height(Math.round(height * scale));
    }
};

Murlsh.closerAdd = function(x, header) {
    var html = (typeof x === 'object') ? $('<div />').append(x).html() : x;

    $.jGrowl(html, {
        closeTemplate : 'X',
        glue : 'before',
        header : header,
        sticky : true,
        beforeOpen : function(e) {
            e.find('.message img').load(function() {
                Murlsh.makeFit($(this),
                    Math.round($(window).width() / 2),
                    Math.round($(window).height() - 100));
            });
        }
    });
};

Murlsh.escapeXml = function(s) {
    return s.replace(/&/g, '&amp;');
};

Murlsh.objectTag = function(data, height, width, params) {
    // this does not use jQuery to build tags because building object
    // tags is broken in IE
    var result = '<object data="' + Murlsh.escapeXml(data) +
        '" height="' + height +
        '" type="application/x-shockwave-flash" width="' + width + '">';

    $.each(params, function(i, v) {
        result += '<param name="' + v.name + '" value="' +
            Murlsh.escapeXml(v.value) + '" />';
    });

    result += '</object>';

    return result;
};

Murlsh.flickrThumb = function(d) {
    var base;
    var owner;
    var photo = d.photo;
    var zoom;

    if (d.stat === 'ok') {
        base = 'http://farm' + photo.farm + '.static.flickr.com/' +
            photo.server + '/' + photo.id + '_';
        zoom = base + photo.secret + '_m.jpg';

        if (photo.originalsecret) {
            zoom = base + photo.originalsecret + '_o.' + photo.originalformat;
        }

        owner = photo.owner;
        return Murlsh.img(base + photo.secret + '_s.jpg',
            photo.title._content +
            (owner && owner.username ? ' by ' + owner.username : '')
            ).addClass('thumb flickr').data('zoom', zoom);
    }
};

Murlsh.flickrClick = function() {
    Murlsh.closerAdd(Murlsh.img($(this).data('zoom')));
};

Murlsh.imgThumb = function() {
    var lastIndex;
    var urlParts = [];

    for (var i = 0; i < arguments.length; i += 1) {
        urlParts.push(arguments[i]);
    }

    lastIndex = urlParts.length - 1;

    // if pdf the thumbnail will be .png
    if (urlParts[lastIndex].match(/^pdf$/i)) {
        urlParts.splice(lastIndex, 1, 'png');
    }

    return Murlsh.img(urlParts.join('')).addClass('thumb');
};

Murlsh.imgClick = function() {
    Murlsh.closerAdd(Murlsh.img($(this).data('href')));
};

Murlsh.twitterThumb = function(d) {
    return Murlsh.img(d.user.profile_image_url).addClass('thumb twitter');
};

Murlsh.twitterAddLinks = function(s) {
    // turn urls into links and Twitter usernames into links to Twitter
    var result = s.replace(
        /https?:\/\/(?:[0-9a-z](?:[0-9a-z\-]{0,61}[0-9a-z])?\.)+[a-z]+\/[0-9a-z$_.+!*'(),\/?#\-]*/gi,
        '<a href="$&">$&</a>');
    result = result.replace(
        /(^|[\s,(])@([0-9a-z_]+)($|[\s,.)])/gi,
        '$1<a href="http://twitter.com/$2">@$2</a>$3');

    return result;
};

Murlsh.vimeoThumb = function(d) {
    return Murlsh.img(d.thumbnail_medium, d.title).addClass('thumb vimeo');
};

Murlsh.vimeoClick = function() {
    Murlsh.closerAdd($(this).data('embedHtml'));
};

Murlsh.youtubeThumb = function(id) {
    return Murlsh.img('http://img.youtube.com/vi/' + id + '/default.jpg',
        'click to watch').addClass('thumb youtube').data('id', id);
};

Murlsh.youtubeClick = function() {
    var movie = 'http://www.youtube.com/v/' + $(this).data('id') + '?' +
        $.param({
            fs : 1,
            hd : 1,
            hl : 'en',
            iv_load_policy : 3,
            showinfo : 0,
            showsearch : 0
        });

    Murlsh.closerAdd(Murlsh.objectTag(movie, 505, 640,
      [{ name : 'movie', value : movie }]));
};

Murlsh.thumbInsert = function(img, clickFunction, a) {
    if (img) {
        if (Murlsh.isIphone()) {
            a.prepend(img);
        } else {
            if (clickFunction) {
                img.click(clickFunction);
            }
            a.before(img);
        }
    }
};

Murlsh.isIphone = function() {
    return navigator.userAgent.match(/i(phone|pod)/i);
};

Murlsh.hrefRes = {
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
};

Murlsh.addExtra = function() {
    var href = $(this).attr('href');
    var match = {};
    var swf = 'swf/player_mp3_mini.swf';
    var thumb;

    $.each(Murlsh.hrefRes, function(x, re) {
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
            success : function(d) {
                Murlsh.thumbInsert(Murlsh.flickrThumb(d),
                    Murlsh.flickrClick, $(this));
            },
            context : $(this),
            jsonpCallback : 'flickrCallback' + match.flickr[1]
        });
    } else if (match.imageshack) {
        Murlsh.thumbInsert(
            Murlsh.imgThumb(match.imageshack[1], 'th.', match.imageshack[2]).data(
                'href', match.imageshack[0]),
            Murlsh.imgClick, $(this).html('imageshack.us'));
    } else if (match.imgur) {
        Murlsh.thumbInsert(
            Murlsh.imgThumb(match.imgur[1], 's', match.imgur[2]).data('href', match.imgur[0]),
            Murlsh.imgClick, $(this).html('imgur.com'));
    } else if (match.mp3) {
        $(this).before(Murlsh.objectTag(swf, 20, 200, [
            { name : 'bgcolor', value : '#000000' },
            { name : 'FlashVars', value : 'mp3=' + href },
            { name : 'movie', value : swf }
        ]));
    } else if (match.s3) {
        thumb = Murlsh.imgThumb(match.s3[1], 'th.', match.s3[2]);

        if (match.s3[2].match(/^pdf$/i)) {
            $(this).before(thumb).html('pdf');
        } else {
            if (Murlsh.isIphone()) {
                $(this).html(thumb);
            } else {
                $(this).html('link');
                $(this).before(thumb.data('href', match.s3[0]).click(
                    Murlsh.imgClick));
            }
        }
    } else if (match.twitter) {
        $.ajax({
            // url : 'http://api.twitter.com/1/statuses/show/' +
            url : '/twitter/1/statuses/show/' +
                match.twitter[1] + '.json',
            dataType : 'jsonp',
            success : function(d) {
                var nameLink = $('<a />', {
                    href: 'http://twitter.com/' + d.user.screen_name + '/status/' + d.id,
                    text: '@' + d.user.screen_name
                });
                var tweet = $('<span />').addClass('tweet').append(nameLink).
                    append(': ').append(Murlsh.twitterAddLinks(d.text));

                Murlsh.thumbInsert(Murlsh.twitterThumb(d), null, nameLink);

                $(this).replaceWith(tweet);
            },
            context : $(this),
            jsonpCallback : 'twitterCallback' + match.twitter[1]
        });
    } else if (match.vimeo) {
        $.ajax({
            url : 'http://vimeo.com/api/v2/video/' + match.vimeo[1] + '.json',
            dataType : 'jsonp',
            success : function(d) {
                var video = d[0];
                var movie = 'http://vimeo.com/moogaloop.swf?clip_id=' + video.id;

                Murlsh.thumbInsert(Murlsh.vimeoThumb(video).data(
                    'embedHtml',
                    Murlsh.objectTag(movie, video.height, video.width, [
                        { name : 'movie', value : movie }
                    ])), Murlsh.vimeoClick, $(this));
            },
            context : $(this),
            jsonpCallback : 'vimeoCallback' + match.vimeo[1]
        });
    } else if (match.youtube) {
        Murlsh.thumbInsert(Murlsh.youtubeThumb(match.youtube[1]),
            Murlsh.youtubeClick, $(this));
    }
};

Murlsh.formatLi = function(d) {
    var iconSize = 32;
    var li = $('<li />').append($('<a />', {
        href : d.url,
        text : d.title
    }));

    if (d.name) {
        li.prepend($('<div />', { text : d.name }).addClass('name'));
    }

    if (d.email) {
        li.prepend($('<div />').addClass('icon').append(
        Murlsh.img(
            'http://www.gravatar.com/avatar/' + d.email + '?s=' + iconSize,
            d.name).attr({
            width : iconSize,
            height : iconSize
        })));
    }

    return li;
};

Murlsh.iphoneInit = function() {
    window.onorientationchange = function() {
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

$(document).ready(function() {
    if (Murlsh.isIphone()) {
        Murlsh.iphoneInit();
    }
    $('a.m').map(Murlsh.addExtra);

    $('#submit').click(function() {
        $.post('url', {
            url : $('#url').val(),
            via : $('#via').val(),
            auth : $('#auth').val()
        }, function (d) {
            $.each(d, function(i, v) {
                var li = Murlsh.formatLi(v);
                $('#urls > li:first').after(li);
                $(li).children('a:first').map(Murlsh.addExtra);
            });
            $('#url').val('');
            $('#via').val('');
        }, 'json');
    });

});
