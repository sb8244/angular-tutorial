APP.controller('WidgetsListController', ['$scope', 'Restangular', function($scope, Restangular) {
  Restangular.all("widgets").getList().then(function(widgets) {
    $scope.widgets = widgets;
  });

  $scope.create = function(widget) {
    Restangular.all("widgets").post(widget).then(function(widget) {
      $scope.widgets.push(widget);
    });
  };
}]);
