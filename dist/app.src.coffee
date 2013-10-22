# portet from py http://www.sthu.org/blog/02-bruttonetto/

class Calculator
    setBrutto: (brutto) ->
        @brutto = parseFloat(brutto)
    
    setType: (@type) ->

    calculate: ->
        {
            brutto: @brutto
            type: @type

            netto: @netPerMonth(1)
            netto13: @netPerMonth(13)
            netto14: @netPerMonth(14)
            nettoYear: @netPerYear() 
        }

    uiPerMonth: ->
        return 0.0 if @brutto <= 1219
        return 1.0 if @brutto <= 1330
        return 2.0 if @brutto <= 1497
        return 3.0

    siPerMonth: (month) ->
        return 0 if @brutto <= 386.80

        hiPerMonth = 3.82
        rates = 10.25 + hiPerMonth + @uiPerMonth()
        rates += 0.5 + 0.5 if (month <= 12)

        return rates / 100.0 * Math.min @brutto, 4400

    itertable: (ref) ->
        net = null

        if (ref <= 1011.43)
            net = 0
        else if (ref <= 2099.33)
            net = ref * 0.365 - 369.173
        else if (ref <= 5016)
            net = ref * 0.4321429 - 510.129
        else
            net = ref * 0.5 - 850.5

        net

    itPerMonth: (month) ->
        ref = @brutto - @siPerMonth(month)
        if (month > 12)
            if(month == 13)
                ref -= 620

            return 0 if @brutto <= 1050
            return ref * 6.0 / 100.0;
        else
            return @itertable(ref);

    netPerMonth: (month) ->
        res = parseFloat((@brutto - @siPerMonth(month) - @itPerMonth(month)).toFixed(2))
        return res if res > 0
        return 0

    netPerYear: ->
        netto = 0
        for month in [1..15] 
            netto += @netPerMonth(month)
        
        netto
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
            if brutto % 200
                continue;
            else
                cC.setBrutto brutto
                res = cC.calculate()
                row = [brutto, brutto, null, res.netto]
                console.log brutto, @brutto
                if (brutto >= @brutto) && isCurrentPlotted == false
                    row[2] = 'You'
                    isCurrentPlotted = true
                chartData.push row

        #data = google.visualization.arrayToDataTable chartData
        data = new google.visualization.DataTable();

        #data.addColumn("string", "Year");
        data.addColumn("number", "Bruttobezug");
        data.addColumn("number", "Bruttobezug");
        data.addColumn({ type: "string", role: "annotation" });
        data.addColumn("number", "Nettobezug");
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
            colors: ['#FA2A00','#3D1C00']
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