class App
    constructor: ->
        @dom()
        @events()
        @changeDataset()

    dom: ->
        @$year = document.querySelector '#year'
        @$type = document.querySelector '#type'
        @$brutto = document.querySelector '#brutto'
        @$netto = document.querySelector '#netto'

    events: ->
        @$type.addEventListener 'change', => @changeDataset()
        @$year.addEventListener 'change', => @changeDataset()
        @$brutto.addEventListener 'keyup', => @calculateNetto()

    changeDataset: () ->
        @data = window['data'+@$year.value+@$type.value]

    calculateNetto: ->
        brutto = Math.round(@$brutto.value / 10) * 10 + '' # we need string here - damn input data
        for row in @data
            if row[0] == brutto
                @$netto.value = row[1]
                return true

        @$netto.value = ''
        console.log "#{brutto} not found"

window.app = new App