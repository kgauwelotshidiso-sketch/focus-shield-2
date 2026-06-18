import 'method_channel_contract.dart';

class MethodChannelPayloadValidator {
  static bool isValidBlockedDomainPayload(Map<dynamic, dynamic> payload) {
    return payload[MethodChannelContract.keyEventType] ==
            MethodChannelContract.eventBlockedDomain &&
        payload[MethodChannelContract.keyDomain] is String &&
        payload[MethodChannelContract.keyCategory] is String &&
        payload[MethodChannelContract.keyReason] is String &&
        payload[MethodChannelContract.keyConfidence] is num &&
        payload[MethodChannelContract.keyTimestamp] is String;
  }

  static bool isValidStatusPayload(Map<dynamic, dynamic> payload) {
    return payload[MethodChannelContract.keyEventType] ==
            MethodChannelContract.eventVpnStatusChanged &&
        payload[MethodChannelContract.keyStatus] is String &&
        payload[MethodChannelContract.keyTimestamp] is String;
  }

  static bool isValidErrorPayload(Map<dynamic, dynamic> payload) {
    return payload[MethodChannelContract.keyEventType] ==
            MethodChannelContract.eventVpnError &&
        payload[MethodChannelContract.keyErrorCode] is String &&
        payload[MethodChannelContract.keyMessage] is String &&
        payload[MethodChannelContract.keyTimestamp] is String;
  }
}
