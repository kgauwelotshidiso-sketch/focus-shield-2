import 'method_channel_contract.dart';

class BlockedDomainPayload {
  final String domain;
  final String category;
  final String reason;
  final double confidence;
  final String timestamp;

  const BlockedDomainPayload({
    required this.domain,
    required this.category,
    required this.reason,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, Object?> toMap() {
    return {
      MethodChannelContract.keyEventType: MethodChannelContract.eventBlockedDomain,
      MethodChannelContract.keyDomain: domain,
      MethodChannelContract.keyCategory: category,
      MethodChannelContract.keyReason: reason,
      MethodChannelContract.keyConfidence: confidence,
      MethodChannelContract.keyTimestamp: timestamp,
    };
  }

  factory BlockedDomainPayload.fromMap(Map<dynamic, dynamic> map) {
    return BlockedDomainPayload(
      domain: map[MethodChannelContract.keyDomain] as String? ?? '',
      category: map[MethodChannelContract.keyCategory] as String? ?? 'unknown',
      reason: map[MethodChannelContract.keyReason] as String? ?? '',
      confidence: (map[MethodChannelContract.keyConfidence] as num?)?.toDouble() ?? 0.0,
      timestamp: map[MethodChannelContract.keyTimestamp] as String? ?? '',
    );
  }
}

class VpnStatusPayload {
  final String status;
  final String message;
  final String timestamp;

  const VpnStatusPayload({
    required this.status,
    required this.message,
    required this.timestamp,
  });

  Map<String, Object?> toMap() {
    return {
      MethodChannelContract.keyEventType: MethodChannelContract.eventVpnStatusChanged,
      MethodChannelContract.keyStatus: status,
      MethodChannelContract.keyMessage: message,
      MethodChannelContract.keyTimestamp: timestamp,
    };
  }

  factory VpnStatusPayload.fromMap(Map<dynamic, dynamic> map) {
    return VpnStatusPayload(
      status: map[MethodChannelContract.keyStatus] as String? ?? MethodChannelContract.statusStopped,
      message: map[MethodChannelContract.keyMessage] as String? ?? '',
      timestamp: map[MethodChannelContract.keyTimestamp] as String? ?? '',
    );
  }
}

class VpnErrorPayload {
  final String errorCode;
  final String message;
  final String timestamp;

  const VpnErrorPayload({
    required this.errorCode,
    required this.message,
    required this.timestamp,
  });

  Map<String, Object?> toMap() {
    return {
      MethodChannelContract.keyEventType: MethodChannelContract.eventVpnError,
      MethodChannelContract.keyErrorCode: errorCode,
      MethodChannelContract.keyMessage: message,
      MethodChannelContract.keyTimestamp: timestamp,
    };
  }

  factory VpnErrorPayload.fromMap(Map<dynamic, dynamic> map) {
    return VpnErrorPayload(
      errorCode: map[MethodChannelContract.keyErrorCode] as String? ?? 'unknown_error',
      message: map[MethodChannelContract.keyMessage] as String? ?? '',
      timestamp: map[MethodChannelContract.keyTimestamp] as String? ?? '',
    );
  }
}
