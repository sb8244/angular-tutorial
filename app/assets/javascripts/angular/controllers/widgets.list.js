APP.controller('WidgetsListController', ['$scope', 'Restangular', function($scope, Restangular) {
  Restangular.all("widgets").getList().then(function(widgets) {
    $scope.widgets = widgets;
  });
}]);
