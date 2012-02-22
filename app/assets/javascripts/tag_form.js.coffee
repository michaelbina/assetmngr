class @TagForm
	constructor: () ->
		self = this
		self.init_tag_inputs()
	
	get_tags_width: (parent) ->
		width = 0
		$(parent).find(".tag").each(() ->
			width += $(this).width()
			width += 15
		)
		return width
		
	place_cursor: (input) ->
		self = this
		
		asset = input.parents(".asset")
		tags_container = asset.find(".tags")[0]
		
		width = self.get_tags_width(tags_container)
		input.css({'padding-left': width+'px'})
	
	add_tag: (input) ->
		self = this
		
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
				self.place_cursor(input)
				return null
		})
		
	init_tag_inputs: () ->
		self = this
		
		$(".add_tag_input").bind('focus', (e) ->
			self.place_cursor($(this))
		) 

		$(".asset input.add_tag_input").keypress((e) ->
			if(e.which == 13)
				input = $(this)
				self.add_tag(input)
		).autocomplete({
			source: '/tags',
			select: () ->
				input = $(this)
				self.add_tag(input)
		})
		
		$(".asset a.remove-tag").live('ajax:success',
			(e, data, textStatus, jqXHR) ->
				input = $(this).parents(".tags-container").find(".add-tag input")
				$(this).parents(".tag").fadeOut().remove()
				self.place_cursor(input)
				return null
		)