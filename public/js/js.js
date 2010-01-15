"use strict";

var Murlsh = {};

Murlsh.tag = function(name, attr, text) {
  var klass;
  var result = $('<' + name + ' />');

  if (attr) {
    if (attr.klass) {
      klass = attr.klass;
      delete attr.klass;
    }
    result.attr(attr);
  }

  if (text) {
    result.text(text);
  }

  if (klass) {
    result.addClass(klass);
  }

  return result;
};

Murlsh.img = function(src, text) {
  text = text || '';
  return Murlsh.tag('img', { 
    src : src,
    alt : text,
    title : text
  });
};

Murlsh.closer_add = function(x, header) {
  var html = (typeof x == 'object') ? Murlsh.tag('div').append(x).html() : x;

  $.jGrowl(html, {
    closeTemplate : 'X',
    glue :'before',
    header : header,
    sticky : true
  });
};

Murlsh.object_tag = function(data, height, width, params) {
  var object = $('<object />').attr({
    data : data,
    height : height,
    type : 'application/x-shockwave-flash',
    width : width
  });

  $.each(params, function(i, v) { object.append($('<param />', v)); });

  return object;
};

Murlsh.flickr_thumb = function(d) {
  var photo = d.photo;
  if (d.stat == 'ok') {
    var base = 'http://farm' + photo.farm + '.static.flickr.com/' +
      photo.server + '/' + photo.id + '_';
    var zoom = base + photo.secret + '_m.jpg';
    if (photo.originalsecret) {
      zoom = base + photo.originalsecret + '_o.' + photo.originalformat;
    }

    var owner = photo.owner;
    return Murlsh.img(base + photo.secret + '_s.jpg',
      photo.title._content +
      (owner && owner.username ? ' by ' + owner.username : '')
      ).addClass('thumb flickr').data('zoom', zoom);
  }
};

Murlsh.flickr_click = function() {
  Murlsh.closer_add(Murlsh.img($(this).data('zoom')));
};

Murlsh.img_thumb = function(prefix, ext) {
  return Murlsh.img(prefix + 'th.' +
    (ext.match(/^pdf$/i) ? 'png' : ext)).addClass('thumb');
};

Murlsh.img_click = function() {
  Murlsh.closer_add(Murlsh.img($(this).data('href')));
};

Murlsh.vimeo_thumb = function(d) {
  return Murlsh.img(d.thumbnail_url, d.title).addClass('thumb vimeo').attr({
    height : d.thumbnail_height,
    width : d.thumbnail_width
  });
};

Murlsh.vimeo_click = function() {
  Murlsh.closer_add($(this).data('embed_html'));
};

Murlsh.youtube_thumb = function(id) {
  return Murlsh.img('http://img.youtube.com/vi/' + id + '/1.jpg',
    'click to watch').addClass('thumb youtube').data('id', id);
};

Murlsh.youtube_click = function() {
  var movie = 'http://www.youtube.com/v/' + $(this).data('id') + '?' +
    $.param({
      hd : 1,
      hl : 'en',
      fs : 1,
      showinfo : 0,
      showsearch : 0
    });
  Murlsh.closer_add(Murlsh.object_tag(movie, 344, 425,
    [{ name : 'movie', value : movie }]));
};

Murlsh.thumb_insert = function(img, click_function, a) {
  if (img) {
    if (Murlsh.is_iphone()) {
      a.prepend(img);
    } else {
      a.before(img.click(click_function));
    }
  }
};

Murlsh.is_iphone = function() {
  return navigator.userAgent.match(/i(phone|pod)/i);
};

Murlsh.href_res = {
  flickr :
    /^http:\/\/(?:www\.)?flickr\.com\/photos\/[^\/]+?\/([0-9]+)/i,
  imageshack :
    /^(http:\/\/img\d+\.imageshack\.us\/img\d+\/\d+\/\w+\.)(jpe?g|gif|png)$/i,
  mp3 :
    /.*\.mp3$/i,
  s3 :
    /^(http:\/\/static\.mmb\.s3\.amazonaws.com\/.*\.)(jpe?g|gif|pdf|png)$/i,
  vimeo :
    /^http:\/\/(?:www\.)?vimeo\.com\/([0-9]+)$/i,
  youtube :
    /^http:\/\/(?:(?:www|uk)\.)?youtube\.com\/watch\?v=(.+?)(?:&|$)/i
};

Murlsh.add_extra = function() {
  var href = $(this).attr('href');
  var match = {};

  $.each(Murlsh.href_res, function(x, re) {
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
      success : function(d) {
        Murlsh.thumb_insert(Murlsh.flickr_thumb(d), Murlsh.flickr_click,
          $(this));
        },
      context : $(this)
    });
  } else if (match.imageshack) {
    Murlsh.thumb_insert(
      Murlsh.img_thumb(match.imageshack[1], match.imageshack[2]).data('href',
        match.imageshack[0]),
      Murlsh.img_click, $(this).html('imageshack.us'));
  } else if (match.mp3) {
    var swf = 'swf/player_mp3_mini.swf';

    $(this).before(Murlsh.object_tag(swf, 20, 200, [
      { name : 'bgcolor', value : '#000000' },
      { name : 'FlashVars', value : 'mp3=' + match.mp3[0] },
      { name : 'movie', value : swf }
    ]));
  } else if (match.s3) {
    var thumb = Murlsh.img_thumb(match.s3[1], match.s3[2]);

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
      url : 'http://vimeo.com/api/oembed.json',
      data : { url : 'http://vimeo.com/' + match.vimeo[1] },
      dataType : 'jsonp',
      success : function(d) {
        Murlsh.thumb_insert(Murlsh.vimeo_thumb(d).data('embed_html',
          d.html.replace(/&/g, '&amp;')),
          Murlsh.vimeo_click, $(this));
        },
      context : $(this)
    });
  } else if (match.youtube) {
    Murlsh.thumb_insert(Murlsh.youtube_thumb(match.youtube[1]),
      Murlsh.youtube_click, $(this));
  }
};

Murlsh.format_li = function(d) {
  var li = Murlsh.tag('li').append(Murlsh.tag('a', { href : d.url }, d.title));

  if (d.name) {
    li.prepend(Murlsh.tag('div', { klass : 'name' }, d.name));
  }

  var icon_size = 32;

  if (d.email) {
    li.prepend(Murlsh.tag('div', { klass : 'icon' }).append(
      Murlsh.img(
        'http://www.gravatar.com/avatar/' + d.email + '?s=' + icon_size,
        d.name).attr({
        width : icon_size,
        height : icon_size
      })));
  }

  return li;
};

Murlsh.iphone_init = function() {
  window.onorientationchange = function() {
    var width = 450;
    if (window.orientation === 0 || window.orientation == 180) {
      width = 290;
    }
    $('#urls').width(width);
  };

  window.onorientationchange();

  $('#urls li:first').prepend(Murlsh.tag('a', { href : '#bottom' }, 'bottom'));
  $('#urls li:last').append(Murlsh.tag('a', { href : '#urls' }, 'top'));
};

$(document).ready(function() {
  if (Murlsh.is_iphone()) {
    Murlsh.iphone_init();
  }
  $('#urls a').map(Murlsh.add_extra);

  $('#submit').click(function() {
    $.post('url', {
      url : $('#url').val(),
      via : $('#via').val(),
      auth : $('#auth').val()
      }, function(d) {
        $.each(d, function(i, v) {
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
