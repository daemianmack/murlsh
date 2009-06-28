function format_li(d) {
  var li = $('<li />').append($('<a />').attr('href', d['url']).text(
    d['title']));

  if (d['name']) {
    li.prepend($('<div />').addClass('name').text(d['name']));
  }

  if (d['email']) {
    li.prepend($('<div />').addClass('icon').append(
      $('<img />').attr({
        src :  'http://www.gravatar.com/avatar/' + d['email'] + '?s=32',
        title : d['name'],
        alt : d['name'],
        width : 32,
        height : 32
      })));
  }

  return li;
}

function object_tag(data, height, width, params) {
  var result = '<object data="' + data + '" height="' + height +
    '" type="application/x-shockwave-flash" width="' + width + '">';
  jQuery.each(params, function(i, v) {
    result += '<param name="' + v.name + '" value="' + v.value + '" />';
  });
  result += '</object>';
  return result;
}

function flickr_click() {
  $('#closer').prepend($('<p />').append($('<img />').attr({
    src : $(this).attr('src').replace(/s\.jpg/, 'm.jpg')
  })));
}

function vimeo_click() {
  $('#closer').prepend($(this).data('embed_html'));
}

function youtube_click() {
  var movie = 'http://www.youtube.com/v/' + $(this).attr('alt') +
    '&amp;hl=en&amp;fs=1&amp;showsearch=0';
  $('#closer').prepend($('<p />').append(object_tag(movie, 344, 425, [
    { name : 'movie', value : movie }
  ])));
}

function add_extra() {
  var flickr_match;
  var mp3_match;
  var vimeo_match;
  var youtube_match;
  var this_a = $(this);
  if (youtube_match = /http:\/\/(?:(?:www|uk)\.)?youtube\.com\/watch\?v=(.+?)(?:&|$)/.exec(
    $(this).attr('href'))) {
    var img = $('<img />').addClass('thumb youtube').attr({
      alt : youtube_match[1],
      src :'http://img.youtube.com/vi/' + youtube_match[1] + '/1.jpg',
      title : 'click to watch'
    });
    if (is_iphone()) {
      $(this).prepend(img);
    } else {
      $(this).before(img.click(youtube_click));
    }
  } else if (flickr_match = /http:\/\/(?:www\.)?flickr\.com\/photos\/[^\/]+?\/([0-9]+)/.exec(
    $(this).attr('href'))) {
    function flickr_thumb_insert(d) {
      var img = $('<img />').addClass('thumb flickr').attr({
        alt : d.photo.title._content,
        src : 'http://farm' + d.photo.farm + '.static.flickr.com/' +
          d.photo.server + '/' + d.photo.id + '_' + d.photo.secret + '_s.jpg',
        title : d.photo.title._content
      });
      if (is_iphone()) {
        this_a.prepend(img);
      } else {
        this_a.before(img.click(flickr_click));
      }
    }
    $.getJSON('http://api.flickr.com/services/rest/?api_key=d04e574aaf11bf2e1c03cba4ee7e5725&method=flickr.photos.getinfo&format=json&photo_id=' +
      flickr_match[1] + '&jsoncallback=?', flickr_thumb_insert);
  } else if (vimeo_match = /^http:\/\/(?:www\.)?vimeo\.com\/([0-9]+)$/.exec(
    $(this).attr('href'))) {
    function vimeo_inject(d) {
      this_a.before($('<img />').addClass('thumb vimeo').attr({
        alt : d.title,
        src : d.thumbnail_url,
        height : d.thumbnail_height,
        width : d.thumbnail_width,
        title : d.title
      }).data('embed_html', d.html).click(vimeo_click));
    }
    $.getJSON('http://vimeo.com/api/oembed.json?url=http%3A//vimeo.com/' +
      vimeo_match[1] + '&callback=?', vimeo_inject);
  } else if (mp3_match = /.*\.mp3$/.exec($(this).attr('href'))) {
    var swf = 'swf/player_mp3_mini.swf';
    $(this).before(object_tag(swf, 20, 200, [
      { name : 'bgcolor', value : '#000000' },
      { name : 'FlashVars', value : 'mp3=' + mp3_match[0] },
      { name : 'movie', value : swf }
    ]));
  }
}

function orientation_changed() {
  if (window.orientation == 0 || window.orientation == 180) {
    $('#urls').width(290);
  } else {
    $('#urls').width(450);
  }
}

window.onorientationchange = orientation_changed;

function is_iphone() {
  return navigator.userAgent.match(/i(phone|pod)/i);
}

$(document).ready(function() {
  orientation_changed();
  $('a').map(add_extra);
  $('#urls li:even').addClass('even');

  $('#submit').click(function() {
    $.post('ajax.cgi', {
      url : $('#url').val(),
      auth : $('#auth').val()
      }, function(d) {
        $.each(d, function(i, v) {
          var li = format_li(v);
          $('#urls > li:first').after(li);
          $(li).children('a:first').map(add_extra);
        });
        $('#url').val('');
      }, 'json');
  });

  if ($.cookie('auth')) {
    $('#auth').val($.cookie('auth'));
  }
});
