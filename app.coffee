class App
    constructor: ->
        @dom()
        @sub()
        @events()
        @changeDataset()

    dom: ->
        @$year = document.querySelector '#year'
        @$type = document.querySelector '#type'
        @$brutto = document.querySelector '#brutto'
        @$netto = document.querySelector '#netto'

    sub: ->
        @calculator = new Calculator

    events: ->
        @$type.addEventListener 'change', => @changeDataset()
        @$year.addEventListener 'change', => @changeDataset()
        #@$brutto.addEventListener 'keydown', (e) => @validateFloat(e)
        @$brutto.addEventListener 'keyup', => @calculateNetto()
        window.addEventListener 'resize', => @drawChart()

    changeDataset: ->
        @calculator.setType @$type.value 

    validateFloat: (e) ->
        charCode = e.which
        if (charCode > 31 && (charCode < 48 || charCode > 57))
            return e.preventDefault()
        return true

    calculateNetto: ->
        @brutto = parseFloat(@$brutto.value);
        @calculator.setBrutto @brutto
        res = @calculator.calculate()
        console.log res
        @$netto.value = res.netto
        @drawChart()
        
    drawChart:() ->
        cC = new Calculator
        cC.setType @$type.value
        isCurrentPlotted = false

        chartData = [] #[[0, 'Bruttobezug', 'Nettobezug', 'annotation']];
        for brutto in [0...7000]
            if brutto % 500
                continue;
            else
                cC.setBrutto brutto
                res = cC.calculate()
                row = [brutto, res.netto, ''+parseInt(res.netto), brutto, null]
                console.log brutto, @brutto
                if (brutto >= @brutto) && isCurrentPlotted == false
                    row[4] = 'You'
                    isCurrentPlotted = true
                chartData.push row

        #data = google.visualization.arrayToDataTable chartData
        data = new google.visualization.DataTable();

        #data.addColumn("string", "Year");
        data.addColumn("number", "Bruttobezug");
        data.addColumn("number", "Bruttobezug");
        data.addColumn({ type: "string", role: "annotation" });
        data.addColumn("number", "Nettobezug");
        data.addColumn({ type: "string", role: "annotation" });
        data.addRows(chartData)
        
        options = { 
            backgroundColor: {
                fill: 'transparent'
                stroke: 'transparent'
                strokeWidth: 0
            }
            interpolateNulls:true
            # backgroundColor.strokeWidth: 0
            chartArea : { top:'1%', height:'98%', left:'1%', width:'98%' }
            curveType: 'function'
            legend: {position: 'none'}
            grid:{borderWidth:0, shadow:false} 
            enableInteractivity: true
            vAxis: {
                baselineColor: 'transparent'
                gridlines: {
                    color: 'transparent'
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
            colors: ['#3D1C00','#FA2A00']
            lineWidth: 1
            pointSize: 3
        }

        chart = new google.visualization.LineChart(document.querySelector('#chart'));
        chart.draw(data, options);


window.app = new App

google.load "visualization", "1", {packages:["corechart"]}
console.log google
google.setOnLoadCallback (e) =>
    window.app.drawChart(google)