APP.controller('WidgetsShowController', ['$scope', 'Restangular', '$stateParams', function($scope, Restangular, $stateParams) {
  Restangular.one("widgets", $stateParams.id).get().then(function(widget) {
    $scope.widget = widget;
  });
}]);
