APP.controller('WidgetsListController', ['Restangular', function(Restangular) {
  var self = this;

  self.newWidget = {};
  self.flags = {
    showCreate: false
  };

  Restangular.all("widgets").getList().then(function(widgets) {
    self.widgets = widgets;
  });

  self.create = function(widget) {
    Restangular.all("widgets").post(widget).then(function(widget) {
      self.widgets.push(widget);
    });
  };

  self.destroy = function(widget) {
    widget.remove().then(function() {
      _.remove(self.widgets, function(w) {
        return w.id === widget.id;
      });
    });
  };
}]);
