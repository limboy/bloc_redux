enum LoadingStatus { notLoading, loading, loaded }
enum LoadingPhase { init, config, content }

class LoadItem {
  LoadingStatus status;
  LoadingPhase phase;
  String description;

  LoadItem(this.status, this.phase, this.description);
}
