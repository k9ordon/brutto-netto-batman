(function() {
  var App, Calculator,
    _this = this;

  Calculator = (function() {
    function Calculator() {}

    Calculator.prototype.setBrutto = function(brutto) {
      return this.brutto = parseFloat(brutto);
    };

    Calculator.prototype.setType = function(type) {
      this.type = type;
    };

    Calculator.prototype.calculate = function() {
      return {
        brutto: this.brutto,
        type: this.type,
        netto: this.netPerMonth(1),
        netto13: this.netPerMonth(13),
        netto14: this.netPerMonth(14),
        nettoYear: this.netPerYear()
      };
    };

    Calculator.prototype.uiPerMonth = function() {
      if (this.brutto <= 1219) {
        return 0.0;
      }
      if (this.brutto <= 1330) {
        return 1.0;
      }
      if (this.brutto <= 1497) {
        return 2.0;
      }
      return 3.0;
    };

    Calculator.prototype.siPerMonth = function(month) {
      var hiPerMonth, rates;
      if (this.brutto <= 386.80) {
        return 0;
      }
      hiPerMonth = 3.82;
      rates = 10.25 + hiPerMonth + this.uiPerMonth();
      if (month <= 12) {
        rates += 0.5 + 0.5;
      }
      return rates / 100.0 * Math.min(this.brutto, 4400);
    };

    Calculator.prototype.itertable = function(ref) {
      var net;
      net = null;
      if (ref <= 1011.43) {
        net = 0;
      } else if (ref <= 2099.33) {
        net = ref * 0.365 - 369.173;
      } else if (ref <= 5016) {
        net = ref * 0.4321429 - 510.129;
      } else {
        net = ref * 0.5 - 850.5;
      }
      return net;
    };

    Calculator.prototype.itPerMonth = function(month) {
      var ref;
      ref = this.brutto - this.siPerMonth(month);
      if (month > 12) {
        if (month === 13) {
          ref -= 620;
        }
        if (this.brutto <= 1050) {
          return 0;
        }
        return ref * 6.0 / 100.0;
      } else {
        return this.itertable(ref);
      }
    };

    Calculator.prototype.netPerMonth = function(month) {
      var res;
      res = parseFloat((this.brutto - this.siPerMonth(month) - this.itPerMonth(month)).toFixed(2));
      if (res > 0) {
        return res;
      }
      return 0;
    };

    Calculator.prototype.netPerYear = function() {
      var month, netto, _i;
      netto = 0;
      for (month = _i = 1; _i <= 15; month = ++_i) {
        netto += this.netPerMonth(month);
      }
      return netto;
    };

    return Calculator;

  })();

  App = (function() {
    function App() {
      this.dom();
      this.sub();
      this.events();
      this.changeDataset();
    }

    App.prototype.dom = function() {
      this.$year = document.querySelector('#year');
      this.$type = document.querySelector('#type');
      this.$brutto = document.querySelector('#brutto');
      return this.$netto = document.querySelector('#netto');
    };

    App.prototype.sub = function() {
      return this.calculator = new Calculator;
    };

    App.prototype.events = function() {
      var _this = this;
      this.$type.addEventListener('change', function() {
        return _this.changeDataset();
      });
      this.$year.addEventListener('change', function() {
        return _this.changeDataset();
      });
      this.$brutto.addEventListener('keyup', function() {
        return _this.calculateNetto();
      });
      return window.addEventListener('resize', function() {
        return _this.drawChart();
      });
    };

    App.prototype.changeDataset = function() {
      return this.calculator.setType(this.$type.value);
    };

    App.prototype.validateFloat = function(e) {
      var charCode;
      charCode = e.which;
      if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return e.preventDefault();
      }
      return true;
    };

    App.prototype.calculateNetto = function() {
      var res;
      this.brutto = parseFloat(this.$brutto.value);
      this.calculator.setBrutto(this.brutto);
      res = this.calculator.calculate();
      console.log(res);
      this.$netto.value = res.netto;
      return this.drawChart();
    };

    App.prototype.drawChart = function() {
      var brutto, cC, chart, chartData, data, isCurrentPlotted, options, res, row, _i;
      cC = new Calculator;
      cC.setType(this.$type.value);
      isCurrentPlotted = false;
      chartData = [];
      for (brutto = _i = 0; _i < 7000; brutto = ++_i) {
        if (brutto % 500) {
          continue;
        } else {
          cC.setBrutto(brutto);
          res = cC.calculate();
          row = [brutto, res.netto, '' + parseInt(res.netto), brutto, null];
          console.log(brutto, this.brutto);
          if ((brutto >= this.brutto) && isCurrentPlotted === false) {
            row[4] = 'You';
            isCurrentPlotted = true;
          }
          chartData.push(row);
        }
      }
      data = new google.visualization.DataTable();
      data.addColumn("number", "Bruttobezug");
      data.addColumn("number", "Bruttobezug");
      data.addColumn({
        type: "string",
        role: "annotation"
      });
      data.addColumn("number", "Nettobezug");
      data.addColumn({
        type: "string",
        role: "annotation"
      });
      data.addRows(chartData);
      options = {
        backgroundColor: {
          fill: 'transparent',
          stroke: 'transparent',
          strokeWidth: 0
        },
        interpolateNulls: true,
        chartArea: {
          top: '1%',
          height: '98%',
          left: '1%',
          width: '98%'
        },
        curveType: 'function',
        legend: {
          position: 'none'
        },
        grid: {
          borderWidth: 0,
          shadow: false
        },
        enableInteractivity: true,
        vAxis: {
          baselineColor: 'transparent',
          gridlines: {
            color: 'transparent'
          },
          viewWindowMode: 'maximized'
        },
        hAxis: {
          format: ' ',
          baselineColor: 'transparent',
          gridlines: {
            color: 'transparent'
          }
        },
        colors: ['#3D1C00', '#FA2A00'],
        lineWidth: 1,
        pointSize: 3
      };
      chart = new google.visualization.LineChart(document.querySelector('#chart'));
      return chart.draw(data, options);
    };

    return App;

  })();

  window.app = new App;

  google.load("visualization", "1", {
    packages: ["corechart"]
  });

  console.log(google);

  google.setOnLoadCallback(function(e) {
    return window.app.drawChart(google);
  });

}).call(this);

/*
//@ sourceMappingURL=app.js.map
*/