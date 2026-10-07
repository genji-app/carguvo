abstract final class SportRunnerProtocol {
  static const String type = 't';

  static const String connect = 'connect';

  static const String setConfig = 'setConfig';

  static const String subscribeList = 'subscribeList';
  static const String unsubscribeList = 'unsubscribeList';

  static const String populate = 'populate';

  static const String querySlice = 'querySlice';

  static const String setHeldEvents = 'setHeldEvents';

  static const String ping = 'ping';

  static const String dispose = 'dispose';

  static const String ready = 'ready';

  static const String status = 'status';

  static const String batch = 'batch';

  static const String populated = 'populated';

  static const String slice = 'slice';

  static const String pong = 'pong';

  static const String log = 'log';

  static const String error = 'error';
}
