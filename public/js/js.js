"use strict";

var Murlsh = {};

Murlsh.new_img = function(src, text) {
  return $('<img />').attr({
    src : src,
    alt : text,
    title : text
  });
};

Murlsh.closer_add = function(x) {
  var html = (typeof x == 'object') ? $('<div />').append(x).html() : x;

  $.jGrowl(html, {
    closeTemplate : 'X',
    glue :'before',
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
  var base = 'http://farm' + d.photo.farm + '.static.flickr.com/' +
    d.photo.server + '/' + d.photo.id + '_';
  var zoom;
  if (d.photo.originalsecret) {
    zoom = base + d.photo.originalsecret + '_o.' + d.photo.originalformat;
  } else {
    zoom = base + d.photo.secret + '_m.jpg';
  }

  return Murlsh.new_img(base + d.photo.secret + '_s.jpg',
    d.photo.title._content).addClass(
    'thumb flickr').data('zoom', zoom);
};

Murlsh.flickr_click = function() {
  Murlsh.closer_add(Murlsh.new_img($(this).data('zoom'), ''));
};

Murlsh.img_thumb = function(prefix, ext) {
  return Murlsh.new_img(prefix + 'th.' + (ext.match(/^pdf$/i) ? 'png' : ext),
    '').addClass('thumb');
};

Murlsh.img_click = function() {
  Murlsh.closer_add(Murlsh.new_img($(this).data('href'), ''));
};

Murlsh.vimeo_thumb = function(d) {
  return Murlsh.new_img(d.thumbnail_url, d.title).addClass('thumb vimeo').attr({
    height : d.thumbnail_height,
    width : d.thumbnail_width
  });
};

Murlsh.vimeo_click = function() {
  Murlsh.closer_add($(this).data('embed_html'));
};

Murlsh.youtube_thumb = function(id) {
  return Murlsh.new_img('http://img.youtube.com/vi/' + id + '/1.jpg',
    'click to watch').addClass('thumb youtube').data('id', id);
};

Murlsh.youtube_click = function() {
  var movie = 'http://www.youtube.com/v/' + $(this).data('id') +
    '?hd=1&amp;hl=en&amp;fs=1&amp;showinfo=0&amp;showsearch=0';
  Murlsh.closer_add(Murlsh.object_tag(movie, 344, 425, [{ name : 'movie', value : movie }]));
};

Murlsh.is_iphone = function() {
  return navigator.userAgent.match(/i(phone|pod)/i);
};

Murlsh.flickr_re =
  /^http:\/\/(?:www\.)?flickr\.com\/photos\/[^\/]+?\/([0-9]+)/i;
Murlsh.imageshack_re =
  /^(http:\/\/img\d+\.imageshack\.us\/img\d+\/\d+\/\w+\.)(jpg|gif|png)$/i;
Murlsh.mp3_re =
  /.*\.mp3$/i;
Murlsh.s3_re =
  /^(http:\/\/static\.mmb\.s3\.amazonaws.com\/.*\.)(jpe?g|gif|pdf|png)$/i;
Murlsh.vimeo_re =
  /^http:\/\/(?:www\.)?vimeo\.com\/([0-9]+)$/i;
Murlsh.youtube_re =
  /^http:\/\/(?:(?:www|uk)\.)?youtube\.com\/watch\?v=(.+?)(?:&|$)/i;

Murlsh.add_extra = function() {
  var this_a = $(this);

  var href = $(this).attr('href');

  var flickr_match = Murlsh.flickr_re.exec(href);
  var imageshack_match = Murlsh.imageshack_re.exec(href);
  var mp3_match = Murlsh.mp3_re.exec(href);
  var s3_match = Murlsh.s3_re.exec(href);
  var vimeo_match = Murlsh.vimeo_re.exec(href);
  var youtube_match = Murlsh.youtube_re.exec(href);

  var thumb;
  var thumb_insert_func;

  if (flickr_match) {
    thumb_insert_func = function flickr_thumb_insert(d) {
      var img = Murlsh.flickr_thumb(d);
      if (Murlsh.is_iphone()) {
        this_a.prepend(img);
      } else {
        this_a.before(img.click(Murlsh.flickr_click));
      }
    };
    $.getJSON('http://api.flickr.com/services/rest/?api_key=d04e574aaf11bf2e1c03cba4ee7e5725&method=flickr.photos.getinfo&format=json&photo_id=' +
      flickr_match[1] + '&jsoncallback=?', thumb_insert_func);
  } else if (imageshack_match) {
    thumb = Murlsh.img_thumb(imageshack_match[1], imageshack_match[2]);
    this_a.html('imageshack.us');
    if (Murlsh.is_iphone()) {
      this_a.prepend(thumb);
    } else {
      this_a.before(thumb.data('href', imageshack_match[0]).click(
        Murlsh.img_click));
    }
  } else if (mp3_match) {
    var swf = 'swf/player_mp3_mini.swf';
    $(this).before(Murlsh.object_tag(swf, 20, 200, [
      { name : 'bgcolor', value : '#000000' },
      { name : 'FlashVars', value : 'mp3=' + mp3_match[0] },
      { name : 'movie', value : swf }
    ]));
  } else if (s3_match) {
    thumb = Murlsh.img_thumb(s3_match[1], s3_match[2]);
    if (s3_match[2].match(/^pdf$/i)) {
	this_a.before(thumb).html('pdf');
    } else {
      if (Murlsh.is_iphone()) {
        this_a.html(thumb);
      } else {
        this_a.html('link');
        this_a.before(thumb.data('href', s3_match[0]).click(Murlsh.img_click));
      }
    }
  } else if (vimeo_match) {
    thumb_insert_func = function vimeo_thumb_insert(d) {
      var img = Murlsh.vimeo_thumb(d);
      if (Murlsh.is_iphone()) {
        this_a.prepend(img);
      } else {
        this_a.before(img.data('embed_html', d.html).click(
          Murlsh.vimeo_click));
      }
    };
    $.getJSON('http://vimeo.com/api/oembed.json?url=http%3A//vimeo.com/' +
      vimeo_match[1] + '&callback=?', thumb_insert_func);
  } else if (youtube_match) {
    var img = Murlsh.youtube_thumb(youtube_match[1]);
    if (Murlsh.is_iphone()) {
      $(this).prepend(img);
    } else {
      $(this).before(img.click(Murlsh.youtube_click));
    }
  }
};

Murlsh.format_li = function(d) {
  var li = $('<li />').append($('<a />').attr('href', d.url).text(
    d.title));

  if (d.name) {
    li.prepend($('<div />').addClass('name').text(d.name));
  }

  var icon_size = 32;

  if (d.email) {
    li.prepend($('<div />').addClass('icon').append(
      Murlsh.new_img(
        'http://www.gravatar.com/avatar/' + d.email + '?s=' + icon_size,
        d.name).attr({
        width : icon_size,
        height : icon_size
      })));
  }

  return li;
};

Murlsh.orientation_changed = function() {
  if (window.orientation === 0 || window.orientation == 180) {
    $('#urls').width(290);
  } else {
    $('#urls').width(450);
  }
};

window.onorientationchange = Murlsh.orientation_changed;

$(document).ready(function() {
  if (Murlsh.is_iphone()) {
    Murlsh.orientation_changed();
    $('#urls li:first').prepend($('<a />').attr('href', '#bottom').text(
      'bottom'));
    $('#urls li:last').append($('<a />').attr('href', '#urls').text('top'));
  }
  $('a').map(Murlsh.add_extra);
  $('#urls li:even').addClass('even');

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
