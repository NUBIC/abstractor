Abstractor = {}
Abstractor.AbstractionUI = ->
  $(document).on "click", ".abstractor_abstraction_value a.edit_link", (e) ->
    e.preventDefault()
    parent_div = $(this).closest(".abstractor_abstraction")
    parent_div.load $(this).attr("href"), ->
      parent_div.find(".combobox").combobox watermark: "a value"
      $(".abstractor_datepicker").datepicker
        altFormat: "yy-mm-dd"
        dateFormat: "yy-mm-dd"
        changeMonth: true
        changeYear: true

      return

    parent_div.addClass "highlighted"
    return

  $(document).on "ajax:success", "form.edit_abstractor_abstraction", (e, data, status, xhr) ->
    parent_div = $(this).closest(".abstractor_abstraction")
    parent_div.html xhr.responseText

    parent_div.removeClass "highlighted"
    return

  $(document).on "click", ".edit_abstractor_abstraction input[type='radio']", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false
    return

  $(document).on "click", ".edit_abstractor_abstraction input[type='checkbox']", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false
    $(this).siblings("input[type='text']").prop "value", ""
    autocompleters = $(this).siblings("select.combobox")
    autocompleters.combobox "setValue", ""
    autocompleters.change()
    $.each $(this).siblings("input[type='radio']"), ->
      if $(this).prop("value") is ""
        $(this).prop "checked", true
      else
        $(this).prop "checked", false
      return

    return

  $(document).on "change", ".edit_abstractor_abstraction select.combobox", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false  if $(this).find("option:selected").prop("value").length
    return

  $(document).on "change", ".edit_abstractor_abstraction input[type='text']", ->
    $(this).siblings("input[type='checkbox']").prop "checked", false
    return

  $(document).on "click", ".abstractor_abstraction_source_tooltip_img", (evt) ->
    target = $(this).attr("rel")
    html = $(target).html()
    title = $(this).attr("title")
    evt.preventDefault()
    $("#abstractor_abstraction_dialog_tooltip").dialog
      maxHeight: 400
      autoOpen: false
      width: 600
      zIndex: 40000
      dialogClass: "ui-dialog_abstractor"
    $("#abstractor_abstraction_dialog_tooltip").html html
    $("#abstractor_abstraction_dialog_tooltip").dialog "option", "title", title
    $("#abstractor_abstraction_dialog_tooltip").dialog "option", "width", ($(window).width() * 0.80)
    $("#abstractor_abstraction_dialog_tooltip").dialog "open"
    return

  $(document).on "change", "select.indirect_source_list", ->
    source_type = $(this).attr("rel")
    value = $(this).find("option:selected").prop("value")
    $(this).siblings(".indirect_source_text").addClass "hidden"
    $(this).siblings("." + source_type + "_" + value).removeClass "hidden"
    return

  return

Abstractor.AbstractionSuggestionUI = ->
  $(document).on "change", ".abstractor_suggestion_status_selection", ->
    $(this).closest("form").submit()
    return

  $(document).on "ajax:success", "form.edit_abstractor_suggestion", (e, data, status, xhr) ->
    $(this).closest(".abstractor_abstraction").html xhr.responseText
    return

  return

Abstractor.AbstractionGroupUI = ->
  $(document).on "ajax:success", ".abstractor_abstraction_group .abstractor_group_delete_link", (e, data, status, xhr) ->
    parent_div = $(this).closest(".abstractor_abstraction_group")
    parent_div.html xhr.responseText
    return

  $(document).on "ajax:success", ".abstractor_subject_groups_container .abstractor_group_add_link", (e, data, status, xhr) ->
    parent_div = $(this).closest(".abstractor_subject_groups_container")
    parent_div.find(".abstractor_subject_groups").append xhr.responseText
    return

  $(document).on "ajax:success", ".abstractor_abstraction_group .abstractor_group_not_applicable_all_link", (e, data, status, xhr) ->
    parent_div = $(this).closest(".abstractor_abstraction_group")
    parent_div.html xhr.responseText
    return

  $(document).on "ajax:success", ".abstractor_abstraction_group .abstractor_group_unknown_all_link", (e, data, status, xhr) ->
    parent_div = $(this).closest(".abstractor_abstraction_group")
    parent_div.html xhr.responseText
    return

  return

new Abstractor.AbstractionUI()
new Abstractor.AbstractionSuggestionUI()
new Abstractor.AbstractionGroupUI()