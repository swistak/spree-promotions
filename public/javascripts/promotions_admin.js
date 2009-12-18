$(document).ready(function(){
  $(".promoted_type").change(function(){
    $('.promoted_name').attr('value', '')
  })

  update = $(document.createElement('div')).
  attr('class', 'auto_complete').
  attr('id', 'promoted_name_auto_complete').
  attr('style', 'display:none');
  $('.promoted_name').after(update);

  jQuery('.promoted_name').autocomplete({
    frequency: 1.5,
    minChars: 3,
    callback: function(element,entry){
      var type = $(".promoted_type").attr('value')
      return(entry + '&promoted_class=' + type)
    },
    update:'promoted_name_auto_complete',
    url:'/admin/product_promotions/auto_complete_for_promoted_name'
  })
});