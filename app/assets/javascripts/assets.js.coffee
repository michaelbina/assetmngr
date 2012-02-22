# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

//= require jquery-ui.min




jQuery ->
	
	get_tags_width = (parent) ->
		width = 0
		$(parent).find(".tag").each(() ->
			width += $(this).width()
			width += 15
		)
		return width
		
	place_cursor = (input) ->
		asset = input.parents(".asset")
		tags_container = asset.find(".tags")[0]
		
		width = get_tags_width(tags_container)
		input.css({'padding-left': width+'px'})
	
	add_tag = (input) ->
		asset = input.parents(".asset")
		asset_id = asset.attr("asset-id")
		
		tags_container = asset.find(".tags")[0]
		
		inputValue = input.val()
		
		$.ajax({
			url: '/assets/' + asset_id + '/add_tag.json'
			type: 'PUT'
			data: {
				tag: inputValue
			},
			success: (data) ->
				$(tags_container).append(data.tag_html)
				input.val("")
				place_cursor(input)
				return null
		})
		
	init_tag_inputs = () ->
		$(".add_tag_input").bind('focus', (e) ->
			place_cursor($(this))
		) 

		$(".asset input.add_tag_input").keypress((e) ->
			if(e.which == 13)
				input = $(this)
				add_tag(input)
		).autocomplete({
			source: '/tags',
			select: () ->
				input = $(this)
				add_tag(input)
		})		
		
	$(".asset a.remove-tag").live('ajax:success',
		(e, data, textStatus, jqXHR) ->
			input = $(this).parents(".tags-container").find(".add-tag input")
			$(this).parents(".tag").fadeOut().remove()
			place_cursor(input)
			return null
	)
	
	## Remove an element
	$(".asset a.delete-asset").live('ajax:success',
		(e, data, textStatus, jqXHR) ->
			el = $(e.target).closest(".asset")
			el.fadeOut()
			return null
	)
	
	init_tag_inputs()

	
	
	$('#upload-button').click((e) ->
		formData = new FormData()
		files = $('#file_select')[0].files
		$.each(files, (i, file) ->
			formData.append("file-"+i, file)
		)
		formData.append("count", files.length)
		$.ajax({
			url: '/assets/add_assets.json',
			type: 'POST',
			data: formData,
			success: (data) ->
				new_assets = data.assets_html
				$.each(new_assets, (index, value) ->
					$("#assets tbody").append(value).children().last().children().each((index, item) -> $(item).effect("highlight", {}, 3000))
				)
				init_tag_inputs()
			error: (data) ->
			cache: false,
			contentType: false,
			processData: false
		})
		null
	)