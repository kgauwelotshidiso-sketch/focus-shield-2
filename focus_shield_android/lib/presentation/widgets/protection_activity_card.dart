import 'package:flutter/material.dart';

import 'protection_truth_cards.dart';

Future<void> Function()? _truthCallback(Object? callback) {
  if (callback is Future<void> Function()) return callback;
  if (callback is void Function()) {
    return () async => callback();
  }
  return null;
}

class ProtectionActivityCard extends StatelessWidget {
  const ProtectionActivityCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.protectionStatus,
    this.state,
    this.appState,
    this.repository,
    this.service,
    this.onRefresh,
    this.onRefreshStatus,
    this.onStatusRefresh,
    this.title = 'Protection Activity',
    this.showCommitment = false,
  });

  final Object? nativeStatus;
  final Object? status;
  final Object? protectionStatus;
  final Object? state;
  final Object? appState;
  final Object? repository;
  final Object? service;
  final Object? onRefresh;
  final Object? onRefreshStatus;
  final Object? onStatusRefresh;
  final String title;
  final bool showCommitment;

  @override
  Widget build(BuildContext context) {
    return ProtectionActivityTruthCard(
      title: title,
      nativeStatus: nativeStatus ?? status ?? protectionStatus,
      showCommitment: showCommitment,
      onRefresh: _truthCallback(
        onRefresh ?? onRefreshStatus ?? onStatusRefresh,
      ),
    );
  }
}

class NativeProtectionCountersCard extends StatelessWidget {
  const NativeProtectionCountersCard({
    super.key,
    this.nativeStatus,
    this.status,
    this.protectionStatus,
    this.state,
    this.appState,
    this.onRefresh,
    this.onRefreshStatus,
    this.onStatusRefresh,
    this.title = 'Protection Activity',
    this.showCommitment = false,
  });

  final Object? nativeStatus;
  final Object? status;
  final Object? protectionStatus;
  final Object? state;
  final Object? appState;
  final Object? onRefresh;
  final Object? onRefreshStatus;
  final Object? onStatusRefresh;
  final String title;
  final bool showCommitment;

  @override
  Widget build(BuildContext context) {
    return ProtectionActivityTruthCard(
      title: title,
      nativeStatus: nativeStatus ?? status ?? protectionStatus,
      showCommitment: showCommitment,
      onRefresh: _truthCallback(
        onRefresh ?? onRefreshStatus ?? onStatusRefresh,
      ),
    );
  }
}
