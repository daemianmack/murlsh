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
  var result = '<object data="' + data + '" height="' + height +
    '" type="application/x-shockwave-flash" width="' + width + '">';
  $.each(params, function(i, v) {
    result += '<param name="' + v.name + '" value="' + v.value + '" />';
  });
  result += '</object>';
  return result;
};

Murlsh.flickr_thumb = function(d) {
  var photo = d.photo;
  if (d.stat == 'ok') {
    var base = 'http://farm' + photo.farm + '.static.flickr.com/' +
      photo.server + '/' + photo.id + '_';
    var zoom;
    if (photo.originalsecret) {
      zoom = base + photo.originalsecret + '_o.' + photo.originalformat;
    } else {
    zoom = base + photo.secret + '_m.jpg';
    }

    var owner = photo.owner;
    return Murlsh.img(base + photo.secret + '_s.jpg',
      photo.title._content +
      (owner && owner.username ? ' by ' + owner.username : '')
      ).addClass('thumb flickr').data('zoom', zoom);
  }
};

Murlsh.flickr_click = function() {
  Murlsh.closer_add(Murlsh.img($(this).data('zoom')), $(this).attr('title'));
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
  var movie = 'http://www.youtube.com/v/' + $(this).data('id') +
    '?hd=1&amp;hl=en&amp;fs=1&amp;showinfo=0&amp;showsearch=0';
  Murlsh.closer_add(Murlsh.object_tag(movie, 344, 425, [{ name : 'movie', value : movie }]));
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
  var this_a = $(this);

  var href = $(this).attr('href');

  var match = {};
  $.each(Murlsh.href_res, function(x, re) { return !(match[x] = re.exec(href)); });

  var thumb;

  if (match.flickr) {
    var callback = function(d) {
      Murlsh.thumb_insert(Murlsh.flickr_thumb(d), Murlsh.flickr_click, this_a);
    };
    $.getJSON('http://api.flickr.com/services/rest/?api_key=d04e574aaf11bf2e1c03cba4ee7e5725&method=flickr.photos.getinfo&format=json&photo_id=' +
      match.flickr[1] + '&jsoncallback=?', callback);
  } else if (match.imageshack) {
    thumb = Murlsh.img_thumb(match.imageshack[1], match.imageshack[2]).data(
      'href', match.imageshack[0]);
    Murlsh.thumb_insert(thumb, Murlsh.img_click, this_a.html('imageshack.us'));
  } else if (match.mp3) {
    var swf = 'swf/player_mp3_mini.swf';
    $(this).before(Murlsh.object_tag(swf, 20, 200, [
      { name : 'bgcolor', value : '#000000' },
      { name : 'FlashVars', value : 'mp3=' + match.mp3[0] },
      { name : 'movie', value : swf }
    ]));
  } else if (match.s3) {
    thumb = Murlsh.img_thumb(match.s3[1], match.s3[2]);
    if (match.s3[2].match(/^pdf$/i)) {
	this_a.before(thumb).html('pdf');
    } else {
      if (Murlsh.is_iphone()) {
        this_a.html(thumb);
      } else {
        this_a.html('link');
        this_a.before(thumb.data('href', match.s3[0]).click(Murlsh.img_click));
      }
    }
  } else if (match.vimeo) {
    var callback = function(d) {
      var thumb = Murlsh.vimeo_thumb(d).data('embed_html', d.html);
      Murlsh.thumb_insert(thumb, Murlsh.vimeo_click, this_a);
    };
    $.getJSON('http://vimeo.com/api/oembed.json?url=http%3A//vimeo.com/' +
      match.vimeo[1] + '&callback=?', callback);
  } else if (match.youtube) {
    thumb = Murlsh.youtube_thumb(match.youtube[1]);
    Murlsh.thumb_insert(thumb, Murlsh.youtube_click, this_a);
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
    if (window.orientation === 0 || window.orientation == 180) {
      $('#urls').width(290);
    } else {
      $('#urls').width(450);
    }
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
      auth : $('#auth').val()
      }, function(d) {
        $.each(d, function(i, v) {
          var li = Murlsh.format_li(v);
          $('#urls > li:first').after(li);
          $(li).children('a:first').map(Murlsh.add_extra);
        });
        $('#url').val('');
      }, 'json');
  });

  if ($.cookie('auth')) {
    $('#auth').val($.cookie('auth'));
  }
});
