$(document).on('ready page:load', function(){
  $('.tag-list-map a').addClass('add-to-token');
  // $('.tag-list-map').replace(/,/g, '');
  $(".token-input-dropdown-facebook").css("z-index","9999");
  $('#tag_form_input').tokenInput('/listings/tags.json', {
    theme: 'facebook',
    prePopulate: $('#tag_form_input').data('load'),
    zindex: 9999,
    preventDuplicates: true,
    allowFreeTagging: true
  })
})
