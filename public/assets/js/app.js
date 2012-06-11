// Generated by CoffeeScript 1.3.3
(function() {
  var $, App, LogEntry, Summary;

  $ = jQuery;

  LogEntry = (function() {

    function LogEntry(object) {
      var name, value;
      for (name in object) {
        value = object[name];
        this[name] = value;
      }
    }

    LogEntry.prototype.extraLine = function(name, text) {
      var escaped_text, icon, label, res;
      if (typeof text === 'function') {
        return "";
      }
      label = "";
      switch (name) {
        case 'time':
          icon = "time";
          text = text.substr(0, 19);
          break;
        case "box":
          icon = "list-alt";
          break;
        case "pid":
          icon = "cog";
          break;
        case "app":
          icon = "home";
          break;
        case "cls":
          icon = "th";
          break;
        case "spr":
          icon = "th-large";
          break;
        case "mth":
          icon = "map-marker";
          break;
        case "fil":
          icon = "file";
          break;
        case "lin":
          icon = "tint";
          break;
        case "line":
        case "original":
          icon = "";
          break;
        case "tyr":
        case "tmo":
        case "tdy":
        case "thr":
        case "tmn":
        case "tsc":
        case "tsu":
          icon = "";
          break;
        default:
          icon = "tag";
          label = name;
      }
      if (icon === "" || text === "") {
        res = "";
      } else {
        escaped_text = Handlebars.Utils.escapeExpression(text);
        if (label === "") {
          res = "<div class=\"lbl\"><span><i class=\"icon-" + icon + "\"></i></span> " + escaped_text + "</div>";
        } else {
          res = "<div class=\"lbl\"><span class=\"txt\"><i class=\"icon-" + icon + "\"></i> " + label + "</span> " + escaped_text + "</div>";
        }
      }
      return res;
    };

    LogEntry.prototype.extraHtml = function() {
      var html, name, value;
      html = '';
      for (name in this) {
        value = this[name];
        html += this.extraLine(name, value);
      }
      return html;
    };

    LogEntry.prototype.toHtml = function() {
      return Handlebars.templates.result(this);
    };

    return LogEntry;

  })();

  Summary = (function() {

    function Summary(object) {
      var name, value;
      this.reset();
      for (name in object) {
        value = object[name];
        this[name] = value;
      }
    }

    Summary.prototype.reset = function() {
      this.app_name = '';
      this.date_str = '';
      this.count = 0;
      this.limit = null;
      this.offset = 0;
      this.size = null;
      return this.searchCount = 0;
    };

    Summary.prototype.canDoMore = function() {
      if (this.size && this.offset > 0) {
        return this.offset < this.size;
      } else {
        return false;
      }
    };

    Summary.prototype.percent = function() {
      if (this.size && this.offset >= 0) {
        return this.offset / this.size * 100;
      } else {
        return false;
      }
    };

    Summary.prototype.percentStr = function() {
      if (this.percent()) {
        return this.percent().toFixed(2) + " %";
      } else {
        return "N/A";
      }
    };

    Summary.prototype.percentInt = function() {
      if (this.percent()) {
        return this.percent().toFixed(0);
      } else {
        return "0";
      }
    };

    Summary.prototype.render = function() {
      return $('#summary').html(this.toHtml());
    };

    Summary.prototype.update = function(data) {
      this.app_name = data.app_name;
      this.date_str = data.date_str;
      this.count += data.count;
      this.limit = data.limit;
      this.offset = data.offset;
      this.size = data.size;
      this.searchCount += 1;
      return this.render();
    };

    Summary.prototype.toHtml = function() {
      return Handlebars.templates.summary(this);
    };

    return Summary;

  })();

  App = {
    summary: new Summary,
    getNames: function() {
      return $.getJSON("/app_names", {
        ajax: "true"
      }, function(data) {
        var option, options, _i, _len;
        options = "";
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          option = data[_i];
          options += "<option>" + option + "</option>";
        }
        return $("#app-name").html(options);
      });
    },
    getDates: function() {
      return $.getJSON("/dates", {
        ajax: "true"
      }, function(data) {
        var option, options, _i, _len;
        options = "";
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          option = data[_i];
          options += "<option>" + option + "</option>";
        }
        return $("#date-str").html(options);
      });
    },
    compileTemplates: function() {
      var html, name, names, template, tplId, _i, _len, _ref;
      if ((_ref = Handlebars.templates) == null) {
        Handlebars.templates = {};
      }
      names = ['summary', 'results', 'result', 'searching', 'no-results', 'error'];
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        name = names[_i];
        tplId = "#" + name + "-template";
        html = $(tplId).html();
        template = Handlebars.compile(html);
        Handlebars.templates[name] = template;
      }
      return Handlebars.templates;
    },
    searchButton: function() {
      return $('#search-btn');
    },
    setButtons: function() {
      return this.searchButton().button();
    },
    spin: function() {
      return this.searchButton().button('loading');
    },
    stopSpin: function() {
      return this.searchButton().button('reset');
    },
    search: function(reset) {
      var options, self, url;
      if (reset == null) {
        reset = true;
      }
      this.spin();
      if (reset) {
        this.summary.reset();
        this.summary.render();
        $('#results').html('');
        $.jGrowl("Searching...");
      }
      url = "/grep/" + ($("#app-name").val());
      options = {
        date: $("#date-str").val(),
        offset: this.summary.offset,
        main: $("#q-main").val()
      };
      self = this;
      return $.getJSON(url, options, function(data) {
        var context, object;
        if (reset) {
          $('#results').html('');
        }
        self.summary.update(data);
        self.stopSpin();
        if (data.count > 0) {
          context = {
            lines: (function() {
              var _i, _len, _ref, _results;
              _ref = data.lines;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                object = _ref[_i];
                _results.push(new LogEntry(object));
              }
              return _results;
            })()
          };
          $('#results').append(Handlebars.templates.results(context));
          if (self.summary.canDoMore() && !self.stopped) {
            return self.search(false);
          } else {
            return self;
          }
        } else {
          return $.jGrowl("No results found...");
        }
      });
    },
    bindOptions: function() {
      var self;
      self = this;
      $("#auto-scroll").bind("change", function() {
        return self.autoScroll(this.checked);
      });
      $("#auto-scroll").attr("checked", true).trigger("change");
      $("#auto-meta").bind("change", function() {
        return self.autoMetaData(this.checked);
      });
      $("#auto-meta").attr("checked", true);
      $("#auto-continue").bind("change", function() {
        return self.autoContinue(this.checked);
      });
      return $("#auto-continue").attr("checked", !this.stopped);
    },
    autoScroll: function(enabled) {
      if (enabled === true) {
        if (this.scroll_fnId) {
          return;
        }
        window._currPos = 0;
        return this.scroll_fnId = setInterval(function() {
          if (window._currPos < document.height) {
            window.scrollTo(0, document.height);
            return window._currPos = document.height;
          }
        }, 100);
      } else {
        if (!this.scroll_fnId) {
          return;
        }
        if (this.scroll_fnId) {
          clearInterval(this.scroll_fnId);
          window._currPost = 0;
          return this.scroll_fnId = null;
        }
      }
    },
    autoMetaData: function(enabled) {
      if (enabled === true) {
        return $("#results div.line div.extra").show();
      } else {
        return $("#results div.line div.extra").hide();
      }
    },
    autoContinue: function(enabled) {
      if (enabled === true) {
        this.stopped = false;
        if (this.summary.canDoMore()) {
          return this.search(false);
        }
      } else {
        return this.stopped = true;
      }
    },
    stopped: true,
    setup: function() {
      this.compileTemplates();
      this.summary.reset();
      this.bindOptions();
      return this.setButtons();
    }
  };

  window.App = App;

  window.LogEntry = LogEntry;

  $(function() {
    App.setup();
    App.getNames();
    App.getDates();
    return $("#search-btn").click(function(event) {
      event.preventDefault();
      return App.search(true);
    });
  });

}).call(this);
