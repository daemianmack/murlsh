/*global $, window*/

"use strict";

var Murlsh = {};

Murlsh.img = function (src, text) {
    text = text || '';
    return $('<img />', {
        src : src,
        alt : text,
        title : text
    });
};

Murlsh.make_fit = function (e, max_width, max_height) {
    var width = e.width(),
        height = e.height(),
        scale;
    if (width > max_width || height > max_height) {
        scale = Math.min(max_width / width, max_height / height);
        e.width(Math.round(width * scale));
        e.height(Math.round(height * scale));
    }
};

Murlsh.closer_add = function (x, header) {
    var html = (typeof x === 'object') ? $('<div />').append(x).html() : x;

    $.jGrowl(html, {
        closeTemplate : 'X',
        glue : 'before',
        header : header,
        sticky : true,
        beforeOpen : function (e) {
            e.find('.message img').load(function () {
                Murlsh.make_fit($(this),
                    Math.round($(window).width() / 2),
                    Math.round($(window).height() - 100));
            });
        }
    });
};

Murlsh.escape_xml = function (s) {
    return s.replace(/&/g, '&amp;');
};

Murlsh.object_tag = function (data, height, width, params) {
    // this does not use jQuery to build tags because building object
    // tags is broken in IE
    var result = '<object data="' + Murlsh.escape_xml(data) +
        '" height="' + height +
        '" type="application/x-shockwave-flash" width="' + width + '">';

    $.each(params, function (i, v) {
        result += '<param name="' + v.name + '" value="' +
            Murlsh.escape_xml(v.value) + '" />';
    });

    result += '</object>';

    return result;
};

Murlsh.flickr_thumb = function (d) {
    var photo = d.photo,
        base,
        owner,
        zoom;
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

Murlsh.flickr_click = function () {
    Murlsh.closer_add(Murlsh.img($(this).data('zoom')));
};

Murlsh.img_thumb = function (prefix, ext) {
    return Murlsh.img(prefix + 'th.' +
        (ext.match(/^pdf$/i) ? 'png' : ext)).addClass('thumb');
};

Murlsh.img_click = function () {
    Murlsh.closer_add(Murlsh.img($(this).data('href')));
};

Murlsh.vimeo_thumb = function (d) {
    return Murlsh.img(d.thumbnail_medium, d.title).addClass('thumb vimeo');
};

Murlsh.vimeo_click = function () {
    Murlsh.closer_add($(this).data('embed_html'));
};

Murlsh.youtube_thumb = function (id) {
    return Murlsh.img('http://img.youtube.com/vi/' + id + '/default.jpg',
        'click to watch').addClass('thumb youtube').data('id', id);
};

Murlsh.youtube_click = function () {
    var movie = 'http://www.youtube.com/v/' + $(this).data('id') + '?' +
        $.param({
            fs : 1,
            hd : 1,
            hl : 'en',
            iv_load_policy : 3,
            showinfo : 0,
            showsearch : 0
        });
    Murlsh.closer_add(Murlsh.object_tag(movie, 505, 640,
      [{ name : 'movie', value : movie }]));
};

Murlsh.thumb_insert = function (img, click_function, a) {
    if (img) {
        if (Murlsh.is_iphone()) {
            a.prepend(img);
        } else {
            a.before(img.click(click_function));
        }
    }
};

Murlsh.is_iphone = function () {
    return navigator.userAgent.match(/i(phone|pod)/i);
};

Murlsh.href_res = {
    flickr :
        /^http:\/\/(?:www\.)?flickr\.com\/photos\/[@\w\-]+?\/([\d]+)/i,
    imageshack :
        /^(http:\/\/img\d+\.imageshack\.us\/img\d+\/\d+\/\w+\.)(jpe?g|gif|png)$/i,
    mp3 :
        /\.mp3$/i,
    s3 :
        /^(http:\/\/static\.mmb\.s3\.amazonaws\.com\/[\w\-]+\.)(jpe?g|gif|pdf|png)$/i,
    vimeo :
        /^http:\/\/(?:www\.)?vimeo\.com\/(\d+)$/i,
    youtube :
        /^http:\/\/(?:(?:www|uk)\.)?youtube\.com\/watch\?v=([\w\-]+)(?:&|$)/i
};

Murlsh.add_extra = function () {
    var href = $(this).attr('href'),
        match = {},
        swf = 'swf/player_mp3_mini.swf',
        thumb;

    $.each(Murlsh.href_res, function (x, re) {
        return !(match[x] = re.exec(href));
    });

    if (match.flickr) {
        $.ajax({
            url : 'http://api.flickr.com/services/rest/',
            data : {
                api_key : 'd04e574aaf11bf2e1c03cba4ee7e5725',
                format : 'json',
                method : 'flickr.photos.getinfo',
                photo_id : match.flickr[1]
            },
            dataType : 'jsonp',
            jsonp : 'jsoncallback',
            success : function (d) {
                Murlsh.thumb_insert(Murlsh.flickr_thumb(d),
                    Murlsh.flickr_click, $(this));
            },
            context : $(this)
        });
    } else if (match.imageshack) {
        Murlsh.thumb_insert(
            Murlsh.img_thumb(match.imageshack[1], match.imageshack[2]).data(
                'href', match.imageshack[0]),
        Murlsh.img_click, $(this).html('imageshack.us'));
    } else if (match.mp3) {
        $(this).before(Murlsh.object_tag(swf, 20, 200, [
            { name : 'bgcolor', value : '#000000' },
            { name : 'FlashVars', value : 'mp3=' + href },
            { name : 'movie', value : swf }
        ]));
    } else if (match.s3) {
        thumb = Murlsh.img_thumb(match.s3[1], match.s3[2]);

        if (match.s3[2].match(/^pdf$/i)) {
            $(this).before(thumb).html('pdf');
        } else {
            if (Murlsh.is_iphone()) {
                $(this).html(thumb);
            } else {
                $(this).html('link');
                $(this).before(thumb.data('href', match.s3[0]).click(
                    Murlsh.img_click));
            }
        }
    } else if (match.vimeo) {
        $.ajax({
            url : 'http://vimeo.com/api/v2/video/' + match.vimeo[1] + '.json',
            dataType : 'jsonp',
            success : function (d) {
                var video = d[0],
                    movie = 'http://vimeo.com/moogaloop.swf?clip_id=' +
                        video.id;
                Murlsh.thumb_insert(Murlsh.vimeo_thumb(video).data(
                    'embed_html',
                    Murlsh.object_tag(movie, video.height, video.width, [
                        { name : 'movie', value : movie }
                    ])), Murlsh.vimeo_click, $(this));
            },
            context : $(this)
        });
    } else if (match.youtube) {
        Murlsh.thumb_insert(Murlsh.youtube_thumb(match.youtube[1]),
            Murlsh.youtube_click, $(this));
    }
};

Murlsh.format_li = function (d) {
    var li = $('<li />').append($('<a />', {
        href : d.url,
        text : d.title
    })),
        icon_size = 32;

    if (d.name) {
        li.prepend($('<div />', { text : d.name }).addClass('name'));
    }

    if (d.email) {
        li.prepend($('<div />').addClass('icon').append(
        Murlsh.img(
            'http://www.gravatar.com/avatar/' + d.email + '?s=' + icon_size,
            d.name).attr({
            width : icon_size,
            height : icon_size
        })));
    }

    return li;
};

Murlsh.iphone_init = function () {
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

$(document).ready(function () {
    if (Murlsh.is_iphone()) {
        Murlsh.iphone_init();
    }
    $('#urls a').map(Murlsh.add_extra);

    $('#submit').click(function () {
        $.post('url', {
            url : $('#url').val(),
            via : $('#via').val(),
            auth : $('#auth').val()
        }, function (d) {
            $.each(d, function (i, v) {
                var li = Murlsh.format_li(v);
                $('#urls > li:first').after(li);
                $(li).children('a:first').map(Murlsh.add_extra);
            });
            $('#url').val('');
            $('#via').val('');
        }, 'json');
    });

    if ($.cookie('auth')) {
        $('#auth').val($.cookie('auth'));
    }
});
