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