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

    drawChart: (google) ->
        console.log @data

        formatedData = [[0, 'Bruttobezug', 'Nettobezug', 'Dienstgeber']];
        for row, idx in @data
            if idx % 20
                continue;
            else
                newRow = []
                newRow.push idx
                for cell, idx in row
                    if idx == 0 || idx == 1 || idx == 4
                        cell = cell.replace '.', ''
                        cell = cell.replace ',', '.'
                        cell = parseInt(cell)
                        newRow.push cell
                        console.log cell
                formatedData.push newRow

        console.log formatedData

        data = google.visualization.arrayToDataTable formatedData
        
        options = { 
            backgroundColor: {
                fill: 'transparent'
                stroke: 'transparent'
                strokeWidth: 0
            }
            # backgroundColor.strokeWidth: 0
            chartArea : { top:'1px', height:'100%', left:'1px', width:'100%' }
            curveType: 'function'
            legend: {position: 'none'}
            grid:{borderWidth:0, shadow:false} 
            enableInteractivity: false
            vAxis: {
                baselineColor: 'transparent'
                gridlines: {
                    color: 'transparent'
                }
                viewWindow: {
                    min: 700
                    max: 7000
                }
                viewWindowMode: 'maximized'
            }
            hAxis: {
                format: ' '
                baselineColor: 'transparent'
                gridlines: {
                    color: 'transparent'
                }
            }
            colors: ['#3D1C00','#FA2A00', '#86B8B1']
            lineWidth: 1
            pointSize: 4
        }

        chart = new google.visualization.LineChart(document.querySelector('#chart'));
        chart.draw(data, options);


window.app = new App

google.load "visualization", "1", {packages:["corechart"]}
console.log google
google.setOnLoadCallback (e) =>
    window.app.drawChart(google)