APP.controller('WidgetsShowController', ['Restangular', '$stateParams', function(Restangular, $stateParams) {
  var self = this;

  Restangular.one("widgets", $stateParams.id).get().then(function(widget) {
    self.widget = widget;
  });
}]);
