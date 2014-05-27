autoSizeText = ->
    elements = $('.resize')
    return if elements.length < 0

    for el in elements
      do (el) ->

        resizeText = ->
          elNewFontSize = (parseInt($(el).css('font-size').slice(0, -2)) - 1) + 'px'
          $(el).css('font-size', elNewFontSize)

        resizeText() while el.scrollHeight > el.offsetHeight
# autoSizeText()