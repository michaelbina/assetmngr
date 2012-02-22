# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

//= require jquery-ui.min
//= require tag_form

jQuery ->
	## initialize a TagForm class which handles all the tag input functions
	tagForm = new TagForm()
	
	## Attach a callback to remove a row when the delete button is clicked
	$(".asset a.delete-asset").live('ajax:success',
		(e, data, textStatus, jqXHR) ->
			el = $(e.target).closest(".asset")
			el.fadeOut()
			return null
	)
		
	## Send file data using ajax when clicking the upload button
	$('#upload-button').click((e) ->
		formData = new FormData()
		files = $('#file_select')[0].files
		$.each(files, (i, file) ->
			formData.append("file-"+i, file)
		)
		formData.append("count", files.length)
		
		setProgress = (e) ->
			percentComplete = (e.loaded / e.total)*100
			$("#progress-bar .bar").css({width: "#{percentComplete}%"})
		
		$.ajax({
			url: '/assets/add_assets.json',
			type: 'POST',
			data: formData,
			success: (data) ->
				# get the new assets html
				new_assets = data.assets_html
				$.each(new_assets, (index, value) ->
					# add the new elements to the table and highlight them
					$("#assets tbody").append(value).children().last().children().each((index, item) -> $(item).effect("highlight", {}, 3000))
				)
				$("#upload-button").removeClass("disabled")
				$("#progress-bar .bar").css({width: "0%"})
				tagForm.init_tag_inputs()
			xhr: () ->
				myXhr = $.ajaxSettings.xhr()
				if(myXhr.upload)
				    myXhr.upload.addEventListener('progress', setProgress, false)
					return myXhr
			error: (data) ->
			beforeSend: () ->
				$("#upload-button").addClass("disabled")
			cache: false,
			contentType: false,
			processData: false
		})
		null
	)