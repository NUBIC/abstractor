Abstractor = {};

Abstractor.AbstractionUI = function(){
  $(document).on('click', '.abstractor_abstraction_value a.edit_link', function(e){
    e.preventDefault();
    parent_div = $(this).closest('.abstractor_abstraction');
    parent_div.load($(this).attr('href'), function(){
      parent_div.find('.combobox').combobox({watermark:'a value'});
      parent_div.find('input[type="submit"], button, a.button').button();
      $('.abstractor_datepicker').datepicker({
        altFormat: 'yy-mm-dd',
        dateFormat: 'yy-mm-dd',
        changeMonth: true,
        changeYear: true
      });
    });
    parent_div.addClass('highlighted');
    //parent_div.siblings('.abstractor_abstraction').block({ message: null, overlayCSS: { opacity: .2 }});
  });
  $(document).on('ajax:success', 'form.edit_abstractor_abstraction', function(e, data, status, xhr){
    parent_div = $(this).closest('.abstractor_abstraction');
    parent_div.html(xhr.responseText);
    //parent_div.siblings('.abstractor_abstraction').unblock();
    parent_div.removeClass('highlighted');
  });
  $(document).on('click', ".edit_abstractor_abstraction input[type='radio']", function(){
    $(this).siblings("input[type='checkbox']").prop('checked',false);
  });
  $(document).on('click', ".edit_abstractor_abstraction input[type='checkbox']", function(){
    $(this).siblings("input[type='checkbox']").prop('checked',false);
    $(this).siblings("input[type='text']").prop('value','');
    var autocompleters = $(this).siblings('select.combobox');
    autocompleters.combobox('setValue', '');
    autocompleters.change();

    $.each($(this).siblings("input[type='radio']"), function(){
      if ($(this).prop('value') === '') {
        $(this).prop('checked',true);
      } else {
        $(this).prop('checked',false);
      }
    });
  });
  $(document).on('change', '.edit_abstractor_abstraction select.combobox', function () {
    if ($(this).find('option:selected').prop('value').length){
      $(this).siblings("input[type='checkbox']").prop('checked',false);
    }
  });
  $(document).on('change', ".edit_abstractor_abstraction input[type='text']", function(){
    $(this).siblings("input[type='checkbox']").prop('checked',false);
  });
  $(document.body).append('<div id="abstractor_abstraction_dialog_tooltip"></div>');

  $(document).on('click','.abstractor_abstraction_source_tooltip_img', function (evt) {
    var target = $(this).attr('rel'),
        html = $(target).html(),
        title = $(this).attr('title');


    evt.preventDefault();
    $('#abstractor_abstraction_dialog_tooltip').html(html);
    $('#abstractor_abstraction_dialog_tooltip').dialog('option', 'title', title);
    $('#abstractor_abstraction_dialog_tooltip').dialog('option', 'width', ($(window).width() * 0.80));
    $('#abstractor_abstraction_dialog_tooltip').dialog('open');
  });

  $('#abstractor_abstraction_dialog_tooltip').dialog({
    maxHeight: 400,
    autoOpen: false,
    width: 600,
    zIndex: 40000,
    dialogClass: "ui-dialog_abstractor"
  });
};

Abstractor.AbstractionSuggestionUI = function(){
  $(document).on('change', '#abstractor_suggestion_abstractor_suggestion_status_id_1, #abstractor_suggestion_abstractor_suggestion_status_id_2, #abstractor_suggestion_abstractor_suggestion_status_id_3', function() {
    $(this).closest('form').submit();
  });

  $(document).on('ajax:success', 'form.edit_abstractor_suggestion', function(e, data, status, xhr){
    $(this).closest('.abstractor_abstraction').html(xhr.responseText);
  });
};

Abstractor.AbstractionGroupUI = function(){
  $(document).on('ajax:success', '.abstractor_abstraction_group .delete_link', function(e, data, status, xhr){
    parent_div = $(this).closest('.abstractor_abstraction_group');
    parent_div.html(xhr.responseText);
  });

  $(document).on('ajax:success', '.abstractor_subject_groups_container .add_link', function(e, data, status, xhr){
    parent_div = $(this).closest('.abstractor_subject_groups_container');
    parent_div.find('.abstractor_subject_groups').append(xhr.responseText);
  });
};
