"use strict"

module = angular.module('mage.table.auth', [
  'mage.hosts',
  'mage.session'
])

module.config ($routeProvider) ->

  $routeProvider
    .when '/auth',
      templateUrl: '/views/auth.html'
      controller: 'mage.table.AuthController'
      resolve:
        pin: (DeviceAuthService, SessionService) ->
          DeviceAuthService.requestAuthPin(SessionService.getUUID())
        reactiveAuth: (MageReactive, SessionService) ->
          MageReactive.connect('/devices/auth', uuid: SessionService.getUUID())


module.controller 'mage.table.AuthController', ($scope, $route, $location, AuthService, SessionService, pin, reactiveAuth) ->
  $scope.pin = pin

  reactiveAuth.once 'device.authenticated', (device) ->
    reactiveAuth.disconnect()
    $scope.$apply ->
      SessionService.setDevice(device)
      AuthService.redirectBack()

