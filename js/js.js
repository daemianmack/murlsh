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

function youtube_click() {
  var movie = 'http://www.youtube.com/v/' + $(this).attr('alt') +
    '&amp;hl=en&amp;fs=1&amp;showsearch=0';
  $(this).replaceWith(object_tag(movie, 344, 425, [
    { name : 'movie', value : movie }
  ]));
}

function add_extra() {
  var flickr_match;
  var mp3_match;
  var vimeo_match;
  var youtube_match;
  var this_a = $(this);
  if (youtube_match = /http:\/\/(?:(?:www|uk)\.)?youtube\.com\/watch\?v=(.+?)(?:&|$)/.exec(
    $(this).attr('href'))) {
    $(this).before($('<img />').addClass('thumb youtube').attr({
      alt : youtube_match[1],
      src :'http://img.youtube.com/vi/' + youtube_match[1] + '/1.jpg',
      title : 'click to watch'
    }).click(youtube_click));
  } else if (flickr_match = /http:\/\/(?:www\.)?flickr\.com\/photos\/[^\/]+?\/([0-9]+)/.exec(
    $(this).attr('href'))) {
    function flickr_thumb_insert(d) {
      this_a.prepend($('<img />').addClass('thumb flickr').attr({
        alt : d.photo.title._content,
        src : 'http://farm' + d.photo.farm + '.static.flickr.com/' +
          d.photo.server + '/' + d.photo.id + '_' + d.photo.secret + '_s.jpg',
        title : d.photo.title._content
      }));
    }
    $.getJSON('http://api.flickr.com/services/rest/?api_key=d04e574aaf11bf2e1c03cba4ee7e5725&method=flickr.photos.getinfo&format=json&photo_id=' +
      flickr_match[1] + '&jsoncallback=?', flickr_thumb_insert);
  } else if (vimeo_match = /^http:\/\/(?:www\.)?vimeo\.com\/([0-9]+)$/.exec(
    $(this).attr('href'))) {
    function vimeo_inject(d) {
      this_a.prepend($('<img />').addClass('thumb vimeo').attr({
        alt : d[0].title,
        src : d[0].thumbnail_small,
        title : d[0].title
      }));
    }
    $.getJSON('http://vimeo.com/api/clip/' + vimeo_match[1] +
      '.json?callback=?', vimeo_inject);
  } else if (mp3_match = /.*\.mp3$/.exec($(this).attr('href'))) {
    var swf = 'swf/player_mp3_mini.swf';
    $(this).before(object_tag(swf, 20, 200, [
      { name : 'bgcolor', value : '#000000' },
      { name : 'FlashVars', value : 'mp3=' + mp3_match[0] },
      { name : 'movie', value : swf }
    ]));
  }
}

$(document).ready(function() {
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
