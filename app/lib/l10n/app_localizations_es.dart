// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'LyraMusic';

  @override
  String get navHome => 'Inicio';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navPlaylists => 'Listas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get splashTagline => 'Música para todos, en todas partes.';

  @override
  String get splashPreparing => 'Preparando tu biblioteca…';

  @override
  String get permTitle => 'Deja que LyraMusic encuentre tus canciones';

  @override
  String get permBody =>
      'LyraMusic necesita leer los archivos de audio de este teléfono para mostrar tus álbumes, artistas y listas. No se sube nada a ningún sitio.';

  @override
  String get permPoint1 => 'Solo lee archivos de audio';

  @override
  String get permPoint1Sub => 'Nunca abre fotos, mensajes ni documentos.';

  @override
  String get permPoint2 => 'Funciona sin internet';

  @override
  String get permPoint2Sub =>
      'El análisis y la reproducción ocurren solo en el teléfono.';

  @override
  String get permPoint3 => 'Tú tienes el control';

  @override
  String get permPoint3Sub =>
      'Puedes retirar el acceso cuando quieras en los ajustes del teléfono.';

  @override
  String get permAllow => 'Permitir acceso a la música';

  @override
  String get permLater => 'Ahora no';

  @override
  String get permFootnote =>
      'Puedes cambiarlo más tarde en los ajustes del teléfono.';

  @override
  String get permDeniedTitle => 'El acceso a la música está desactivado';

  @override
  String get permDeniedBody =>
      'Sin acceso a tus archivos de audio, tu biblioteca queda vacía.';

  @override
  String get permOpenSettings => 'Abrir ajustes del teléfono';

  @override
  String get scanning => 'Analizando tu música…';

  @override
  String scanProgress(int done, int total) {
    return '$done de $total archivos';
  }

  @override
  String scanResult(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones en tu biblioteca',
      one: '1 canción en tu biblioteca',
      zero: 'No se encontraron canciones',
    );
    return '$_temp0';
  }

  @override
  String get scanError => 'No se pudo analizar la biblioteca.';

  @override
  String get rescan => 'Analizar';

  @override
  String get scanMusic => 'Buscar música';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String homeHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones, todas en tu teléfono',
      one: '1 canción, en tu teléfono',
      zero: 'Todavía no hay canciones',
    );
    return '$_temp0';
  }

  @override
  String get resumePlayback => 'Reanudar';

  @override
  String timeLeft(String time) {
    return 'Quedan $time';
  }

  @override
  String get recentlyAdded => 'Añadidas recientemente';

  @override
  String get recentlyPlayed => 'Escuchadas recientemente';

  @override
  String get recentlyFavorited => 'Favoritos recientes';

  @override
  String get yourPlaylists => 'Tus listas';

  @override
  String get manage => 'Gestionar';

  @override
  String get allFavorites => 'Todos los favoritos';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get badgeNew => 'Nuevo';

  @override
  String get badgeFix => 'Completar';

  @override
  String localLibraryFooter(String songs) {
    return 'Biblioteca local · $songs';
  }

  @override
  String get shuffleAll => 'Todo aleatorio';

  @override
  String get play => 'Reproducir';

  @override
  String get playAll => 'Reproducir todo';

  @override
  String get pause => 'Pausa';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get shuffle => 'Aleatorio';

  @override
  String get shuffleOn => 'Aleatorio activado';

  @override
  String get shuffleOff => 'Aleatorio desactivado';

  @override
  String get repeatOff => 'Repetición desactivada';

  @override
  String get repeatAll => 'Repetir todo';

  @override
  String get repeatOne => 'Repetir canción';

  @override
  String get library => 'Biblioteca';

  @override
  String get tabSongs => 'Canciones';

  @override
  String get tabArtists => 'Artistas';

  @override
  String get tabAlbums => 'Álbumes';

  @override
  String get tabGenres => 'Géneros';

  @override
  String get tabFolders => 'Carpetas';

  @override
  String songsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
    );
    return '$_temp0';
  }

  @override
  String albumsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count álbumes',
      one: '1 álbum',
    );
    return '$_temp0';
  }

  @override
  String get unknownArtist => 'Artista desconocido';

  @override
  String get unknownAlbum => 'Álbum desconocido';

  @override
  String get unknownGenre => 'Género desconocido';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortTitle => 'Título';

  @override
  String get sortArtist => 'Artista';

  @override
  String get sortAlbum => 'Álbum';

  @override
  String get sortDateAdded => 'Añadidas recientemente';

  @override
  String incompleteBannerTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos tienen información incompleta',
      one: '1 archivo tiene información incompleta',
    );
    return '$_temp0';
  }

  @override
  String get incompleteBannerText =>
      'LyraMusic nunca inventa etiquetas. Revísalas cuando quieras.';

  @override
  String get reviewFiles => 'Revisar archivos';

  @override
  String get incompleteTitle => 'Canciones por completar';

  @override
  String get foldersHint =>
      'Solo se muestran las carpetas que contienen audio.';

  @override
  String get searchSubtitle => 'Solo en tu teléfono';

  @override
  String get searchHint => 'Canciones, artistas, álbumes, listas';

  @override
  String get recentSearches => 'Búsquedas recientes';

  @override
  String get browseBy => 'Explorar por';

  @override
  String get clear => 'Borrar';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String searchNoResults(String query) {
    return 'Sin resultados para «$query»';
  }

  @override
  String get searchNoResultsText =>
      'Revisa la ortografía o vuelve a analizar si la canción se añadió hace poco.';

  @override
  String resultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0';
  }

  @override
  String get emptyLibraryTitle => 'No se encontró música';

  @override
  String get emptyLibraryBody =>
      'Copia archivos MP3, FLAC o M4A a este teléfono y vuelve a analizar la biblioteca.';

  @override
  String get playlists => 'Listas';

  @override
  String localPlaylists(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listas locales',
      one: '1 lista local',
      zero: 'Ninguna lista local',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favoritos';

  @override
  String get history => 'Historial';

  @override
  String get newPlaylist => 'Nueva lista';

  @override
  String get playlistName => 'Nombre de la lista';

  @override
  String get create => 'Crear';

  @override
  String get rename => 'Renombrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get change => 'Cambiar';

  @override
  String get toggleView => 'Cambiar vista';

  @override
  String get deletePlaylistTitle => '¿Eliminar esta lista?';

  @override
  String deletePlaylistBody(String name) {
    return 'Se eliminará «$name». Tus archivos de música no se borran.';
  }

  @override
  String get playlistCreated => 'Lista creada';

  @override
  String addedToPlaylist(String name) {
    return 'Añadido a $name';
  }

  @override
  String get playlistsLocalTitle => 'Las listas viven en este teléfono';

  @override
  String get playlistsLocalText =>
      'Nada se sincroniza ni se sube. Una canción puede aparecer varias veces en la misma lista.';

  @override
  String get emptyPlaylistTitle => 'Esta lista está vacía';

  @override
  String get emptyPlaylistBody => 'Añade canciones para empezar a escuchar.';

  @override
  String get noPlaylistsTitle => 'Todavía no hay listas';

  @override
  String get noPlaylistsBody =>
      'Crea una lista para agrupar las canciones que te gustan.';

  @override
  String get noFavoritesTitle => 'Todavía no hay favoritos';

  @override
  String get noFavoritesBody =>
      'Toca el corazón de una canción para encontrarla aquí.';

  @override
  String get addedToFavorites => 'Añadido a favoritos';

  @override
  String get removedFromFavorites => 'Eliminado de favoritos';

  @override
  String get addSongs => 'Añadir canciones';

  @override
  String get searchSongs => 'Buscar canciones';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones seleccionadas',
      one: '1 canción seleccionada',
      zero: 'Ninguna canción seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get historyToday => 'Hoy';

  @override
  String get historyYesterday => 'Ayer';

  @override
  String get historyThisWeek => 'Esta semana';

  @override
  String get historyEarlier => 'Antes';

  @override
  String get clearHistory => 'Borrar historial';

  @override
  String get clearHistoryTitle => '¿Borrar el historial de escucha?';

  @override
  String get clearHistoryBody =>
      'Tus canciones, favoritos y listas no se ven afectados.';

  @override
  String get historyEmptyTitle => 'Todavía no hay historial';

  @override
  String get historyEmptyBody => 'Las canciones que escuches aparecerán aquí.';

  @override
  String get playNext => 'Reproducir a continuación';

  @override
  String get addToQueue => 'Añadir a la cola';

  @override
  String get addToPlaylist => 'Añadir a una lista';

  @override
  String get addToFavorites => 'Añadir a favoritos';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get goToArtist => 'Ir al artista';

  @override
  String get goToAlbum => 'Ir al álbum';

  @override
  String get songDetails => 'Detalles de la canción';

  @override
  String get editTags => 'Editar información';

  @override
  String get removeFromPlaylist => 'Quitar de la lista';

  @override
  String get willPlayNext => 'Sonará a continuación';

  @override
  String get addedToQueue => 'Añadido a la cola';

  @override
  String get nowPlaying => 'Reproduciendo';

  @override
  String fromAlbum(String album) {
    return 'de $album';
  }

  @override
  String get queue => 'Cola';

  @override
  String get playingQueue => 'Cola de reproducción';

  @override
  String get upNext => 'A continuación';

  @override
  String nextUpCount(int count) {
    return 'A continuación · $count';
  }

  @override
  String get dragToReorder => 'Arrastra para reordenar';

  @override
  String get shuffleQueue => 'Mezclar la cola';

  @override
  String get queueCleared => 'Cola vaciada';

  @override
  String get queueEmpty => 'La cola está vacía';

  @override
  String get queueEmptyBody =>
      'Añade canciones desde tu biblioteca, un álbum o una lista para seguir escuchando.';

  @override
  String get openLibrary => 'Abrir biblioteca';

  @override
  String get removeFromQueue => 'Quitar de la cola';

  @override
  String get lyrics => 'Letra';

  @override
  String get lyricsSynced => 'Letra sincronizada';

  @override
  String get lyricsUnsynced => 'No sincronizada';

  @override
  String get lyricsStoredLocally =>
      'Guardada en el teléfono · disponible sin conexión';

  @override
  String get lyricsUnavailable => 'Letra no disponible';

  @override
  String get lyricsNoneText =>
      'Este archivo no contiene letra y no se encontró ningún archivo .lrc con el mismo nombre a su lado.';

  @override
  String get detailsFile => 'Archivo';

  @override
  String get detailsFormat => 'Formato';

  @override
  String get detailsBitrate => 'Tasa de bits';

  @override
  String get detailsSampleRate => 'Muestreo';

  @override
  String get detailsDuration => 'Duración';

  @override
  String get detailsSize => 'Tamaño del archivo';

  @override
  String get detailsLocation => 'Ubicación';

  @override
  String get detailsTags => 'Etiquetas';

  @override
  String get badgeMissing => 'Falta';

  @override
  String get badgeIncomplete => 'Incompleto';

  @override
  String get missingInfoTitle => 'Falta información';

  @override
  String get missingInfoText =>
      'LyraMusic nunca inventa etiquetas. El archivo se reproduce con normalidad; puedes completarlo cuando quieras.';

  @override
  String get chooseArtwork => 'Elegir portada';

  @override
  String fileOfType(String format) {
    return 'Archivo $format';
  }

  @override
  String get fieldTitle => 'Título';

  @override
  String get fieldArtist => 'Artista';

  @override
  String get fieldAlbum => 'Álbum';

  @override
  String get fieldAlbumArtist => 'Artista del álbum';

  @override
  String get fieldGenre => 'Género';

  @override
  String get fieldYear => 'Año';

  @override
  String get fieldTrackNumber => 'N.º de pista';

  @override
  String get titleRequired => 'El título no puede estar vacío';

  @override
  String get yearInvalid => '4 cifras';

  @override
  String get numberInvalid => 'Introduce un número';

  @override
  String get notSupportedForFormat => 'No disponible para este formato';

  @override
  String get artwork => 'Portada';

  @override
  String get artworkEmbedded => 'Incluida en el archivo';

  @override
  String get artworkNew => 'Nueva portada, se guardará con el archivo';

  @override
  String get artworkChoose => 'Elegir de la galería';

  @override
  String get artworkRemove => 'Quitar la portada';

  @override
  String get artworkNone => 'Este archivo no tiene portada';

  @override
  String get tagsWriteInfo =>
      'Los cambios se escriben directamente en el archivo de audio. Android te pedirá permiso.';

  @override
  String get tagsSaved => 'Etiquetas guardadas en el archivo';

  @override
  String get tagsErrorDenied =>
      'Se denegó el permiso para modificar este archivo. No se cambió nada.';

  @override
  String get tagsErrorWrite =>
      'No se pudo modificar el archivo. El archivo original no ha cambiado.';

  @override
  String get discardTitle => '¿Descartar los cambios?';

  @override
  String get discardBody => 'Tus cambios no se han guardado.';

  @override
  String get discard => 'Descartar';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get settings => 'Ajustes';

  @override
  String get groupAppearance => 'Apariencia';

  @override
  String get groupLibrary => 'Biblioteca';

  @override
  String get groupData => 'Datos';

  @override
  String get groupSystem => 'Sistema';

  @override
  String get groupAbout => 'Acerca de';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma del teléfono';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get permissions => 'Permisos';

  @override
  String get permissionGranted => 'Acceso a la música concedido';

  @override
  String get privacy => 'Privacidad';

  @override
  String get privacyValue => 'Sin cuenta, sin seguimiento, sin nube';

  @override
  String get licences => 'Licencias de código abierto';

  @override
  String get version => 'Versión';

  @override
  String get settingsFooter =>
      'Tu música nunca sale de este teléfono. No se necesita conexión a internet.';

  @override
  String get cannotPlay =>
      'No se puede reproducir este archivo. Puede que se haya movido o eliminado.';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get appearance => 'Apariencia';

  @override
  String get accentColor => 'Color principal';

  @override
  String get accentHint =>
      'Se usa en los botones, la canción actual y los controles activos.';

  @override
  String get accentClassic => 'Clásico';

  @override
  String get accentSand => 'Arena';

  @override
  String get accentTaupe => 'Topo';

  @override
  String get accentSage => 'Salvia';

  @override
  String get accentTerracotta => 'Terracota';

  @override
  String get accentOcean => 'Océano';

  @override
  String get accentMint => 'Menta';

  @override
  String get accentViolet => 'Violeta';

  @override
  String get preview => 'Vista previa';

  @override
  String get listenNow => 'Escuchar ahora';

  @override
  String get playerLayout => 'Pantalla de reproducción';

  @override
  String get playerLayoutSub => 'Elige qué se muestra';

  @override
  String get playerLayoutHint =>
      'Muestra u oculta cada elemento del reproductor, la cola y el minirreproductor.';

  @override
  String get artRounded => 'Redondeada';

  @override
  String get artSquare => 'Cuadrada';

  @override
  String get artVinyl => 'Vinilo';

  @override
  String get bgBlur => 'Desenfocada';

  @override
  String get bgGradient => 'Degradado';

  @override
  String get bgPlain => 'Liso';

  @override
  String get optSwipe => 'Deslizar la portada';

  @override
  String get optSwipeSub => 'Izquierda: siguiente · derecha: anterior';

  @override
  String get groupInfo => 'Información';

  @override
  String get optAlbumInfo => 'Álbum y año';

  @override
  String get optFormat => 'Formato de audio';

  @override
  String get optRemaining => 'Tiempo restante';

  @override
  String get optRemainingSub => 'Si no, se muestra la duración total';

  @override
  String get optNextUp => 'Vista previa de la siguiente';

  @override
  String get groupControls => 'Controles';

  @override
  String get optVolume => 'Volumen';

  @override
  String get optVolumeSub => 'El mismo que los botones del teléfono';

  @override
  String get optFavorite => 'Botón de favorito';

  @override
  String get optShuffleRepeat => 'Aleatorio y repetición';

  @override
  String get groupActionBar => 'Barra de acciones';

  @override
  String get sleepTimer => 'Temporizador';

  @override
  String get playbackSpeed => 'Velocidad';

  @override
  String get equalizer => 'Ecualizador';

  @override
  String get optQueueNowPlaying => 'Tarjeta «Reproduciendo»';

  @override
  String get optQueueArtwork => 'Portadas';

  @override
  String get optQueueDuration => 'Duraciones';

  @override
  String get optQueueSwipe => 'Deslizar para quitar';

  @override
  String get miniPlayer => 'Minirreproductor';

  @override
  String get optMiniProgress => 'Barra de progreso';

  @override
  String get optMiniNext => 'Botón siguiente';

  @override
  String get resetLayout => 'Restablecer';

  @override
  String get resetLayoutDone => 'Diseño por defecto restablecido';

  @override
  String get sleepTimerOff => 'Temporizador desactivado';

  @override
  String get sleepEndOfTrack => 'Al final de la canción';

  @override
  String sleepIn(int minutes) {
    return 'Se detiene en $minutes min';
  }

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get speedHint => 'Se conserva el tono.';

  @override
  String get eqFlat => 'Plano';

  @override
  String get eqBass => 'Graves';

  @override
  String get eqVocal => 'Voz';

  @override
  String get eqElectronic => 'Electrónica';

  @override
  String get eqClassical => 'Clásica';

  @override
  String get audio => 'Audio';

  @override
  String get eqUnavailable =>
      'Reproduce una canción para ajustar el ecualizador.';

  @override
  String get bassBoost => 'Amplificación';

  @override
  String get eqHint =>
      'Los ajustes se guardan y se aplican a todas las canciones.';

  @override
  String get groupPlayback => 'Reproducción';

  @override
  String get on => 'Activado';

  @override
  String get off => 'Desactivado';

  @override
  String get skipSilence => 'Saltar silencios';

  @override
  String get skipSilenceSub => 'Salta las partes en silencio';

  @override
  String get lockScreen => 'Pantalla de bloqueo';

  @override
  String get lockScreenOption => 'LyraMusic en la pantalla de bloqueo';

  @override
  String get lockScreenSub =>
      'Muestra el reproductor al bloquear el teléfono durante la reproducción';

  @override
  String get lockPermissionBody =>
      'Para mostrar el reproductor sobre la pantalla de bloqueo, Android necesita tu permiso (notificaciones a pantalla completa). Se abrirán los ajustes: activa la opción para LyraMusic y vuelve.';

  @override
  String get allow => 'Permitir';

  @override
  String get lockPermissionMissing => 'Permiso necesario';

  @override
  String get lockPermissionMissingSub =>
      'Toca para abrir los ajustes de Android';

  @override
  String get widgets => 'Widgets de pantalla de inicio';

  @override
  String get widgetSmall => 'Widget compacto (4 × 1)';

  @override
  String get widgetSmallSub => 'Canción y controles · toca para añadir';

  @override
  String get widgetLarge => 'Widget reproductor (4 × 2)';

  @override
  String get widgetLargeSub => 'Portada grande · toca para añadir';

  @override
  String get widgetManual =>
      'Mantén pulsada la pantalla de inicio y luego Widgets › LyraMusic.';

  @override
  String get suggestions => 'Sugerencias';

  @override
  String get mostPlayed => 'Más escuchadas';

  @override
  String get sortName => 'Nombre';

  @override
  String get sortSongCount => 'Número de canciones';

  @override
  String get ascending => 'Ascendente';

  @override
  String get descending => 'Descendente';

  @override
  String artistsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artistas',
      one: '1 artista',
    );
    return '$_temp0';
  }

  @override
  String foldersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carpetas',
      one: '1 carpeta',
    );
    return '$_temp0';
  }

  @override
  String genresCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count géneros',
      one: '1 género',
    );
    return '$_temp0';
  }

  @override
  String get newPlaylistSub => 'Elige un nombre y canciones';

  @override
  String get searchIntro => 'Busca en tu música';

  @override
  String get clearAll => 'Borrar todo';

  @override
  String get back10 => 'Retroceder 10 segundos';

  @override
  String get forward10 => 'Avanzar 10 segundos';

  @override
  String get optSeekButtons => 'Botones ±10 s';

  @override
  String get optSeekButtonsSub =>
      'Sustituyen aleatorio y repetición junto a Reproducir (pasan a la fila de abajo)';

  @override
  String get skip => 'Saltar';

  @override
  String get getStarted => 'Empezar';

  @override
  String get onb1Title => 'Toda tu música, en tu teléfono';

  @override
  String get onb1Body =>
      'Sin conexión. Sin cuenta, sin streaming, sin anuncios.';

  @override
  String get onb2Title => 'Etiquetas limpias, sin ordenador';

  @override
  String get onb2Body =>
      'Corrige títulos, artistas y portadas directamente en tus archivos.';

  @override
  String get onb3Title => 'Letras que siguen la música';

  @override
  String get onb3Body =>
      'Letras sincronizadas, widgets y reproductor en la pantalla de bloqueo.';

  @override
  String get onbLyrics =>
      'La música nos une|Una banda sonora|para cada historia|Música para todos,|en todas partes';

  @override
  String get auto => 'Auto';

  @override
  String get edit => 'Editar';

  @override
  String get hapticsLabel => 'Vibración';

  @override
  String get hapticsSub => 'Respuesta táctil en los gestos';

  @override
  String get themeDynamic => 'Portada';

  @override
  String get themeClassic => 'Clásico';

  @override
  String get themesGalleryHint => 'Elige un ambiente o crea el tuyo.';

  @override
  String get themeDynamicHint =>
      'Los colores siguen la portada de la canción actual.';

  @override
  String get themeCreate => 'Crear un tema';

  @override
  String get themeEdit => 'Editar tema';

  @override
  String get themeMine => 'Mi tema';

  @override
  String get themeSaved => 'Tema guardado y aplicado';

  @override
  String get themeSurprise => 'Sorpréndeme';

  @override
  String get themeName => 'Nombre del tema';

  @override
  String get themeColors => 'Colores';

  @override
  String get themeBackground => 'Fondo';

  @override
  String get themeText => 'Texto';

  @override
  String get themeContrastLow => 'Legibilidad baja';

  @override
  String get themeContrastOk => 'Buena legibilidad';

  @override
  String themeContrastText(String ratio) {
    return 'Contraste del texto: $ratio:1 (4,5 recomendado)';
  }

  @override
  String get themeTipDark =>
      'Consejo: un fondo muy oscuro ahorra batería en pantallas OLED.';

  @override
  String get themeTipLight =>
      'Consejo: un fondo crema es más suave para la vista que el blanco puro.';

  @override
  String get lyricsMenu => 'Letra…';

  @override
  String get lyricsSaved => 'Letra guardada en el teléfono';

  @override
  String get lyricsEditTitle => 'Letra';

  @override
  String get lyricsDelete => 'Eliminar mi letra';

  @override
  String get lyricsDeleted => 'Letra eliminada';

  @override
  String get paste => 'Pegar';

  @override
  String get lyricsHint2 => 'Pega o escribe la letra, una línea por frase.';

  @override
  String linesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count líneas',
      one: '1 línea',
      zero: 'Ninguna línea',
    );
    return '$_temp0';
  }

  @override
  String get syncNow => 'Sincronizar';

  @override
  String get syncSaved => 'Letra sincronizada guardada';

  @override
  String get syncReview => 'Revisar';

  @override
  String get syncTitle => 'Sincronizar letra';

  @override
  String syncProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get syncReviewHint =>
      'Toca una línea para escucharla y ajustar su momento.';

  @override
  String get syncHint => 'Toca el botón justo cuando empieza cada línea.';

  @override
  String get syncUndo => 'Deshacer';

  @override
  String get syncRestart => 'Empezar de nuevo';

  @override
  String get syncTap => 'Línea siguiente';

  @override
  String get syncShiftAll => 'Desplazar todo';

  @override
  String syncAdjustLine(int line) {
    return 'Ajustar línea $line';
  }

  @override
  String get syncPlayAll => 'Escuchar desde el inicio';

  @override
  String get syncListen => 'Escuchar';

  @override
  String get workshop => 'Taller';

  @override
  String get workshopSub => 'Letras y datos por completar';

  @override
  String get wsNoLyrics => 'Sin letra';

  @override
  String get wsToSync => 'Por sincronizar';

  @override
  String get wsSynced => 'Sincronizadas';

  @override
  String get wsMissingInfo => 'Datos faltantes';

  @override
  String get wsAdd => 'Añadir';

  @override
  String get wsSync => 'Sincro';

  @override
  String get wsEdit => 'Editar';

  @override
  String get wsComplete => 'Completar';

  @override
  String get wsEmptyNone => 'Todas tus canciones tienen letra.';

  @override
  String get wsEmptyPlain => 'Nada que sincronizar por ahora.';

  @override
  String get wsEmptySynced => 'Aún no hay letras sincronizadas.';

  @override
  String get wsEmptyInfo => 'Todos los datos están completos.';

  @override
  String get wsProgressTitle => 'Letras sincronizadas';

  @override
  String wsProgressBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aportes guardados en el teléfono',
      one: '1 aporte guardado en el teléfono',
      zero: 'Aún no hay aportes',
    );
    return '$_temp0';
  }

  @override
  String get wsAllDone => '¡Biblioteca completa, bravo!';

  @override
  String wsCountNone(int count) {
    return '$count sin letra';
  }

  @override
  String wsCountPlain(int count) {
    return '$count por sincronizar';
  }

  @override
  String wsCountInfo(int count) {
    return '$count por completar';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get guideLink => '¿Cómo funciona el Taller?';

  @override
  String get guideStart => '¡Vamos!';

  @override
  String get guide1Title => 'Añade letras';

  @override
  String get guide1Body =>
      'Pega o escribe la letra, una línea por frase. Se guarda en tu teléfono, sin tocar el archivo.';

  @override
  String get guide2Title => 'Sincroniza al ritmo';

  @override
  String get guide2Body =>
      'Reproduce la canción y toca el botón al empezar cada línea. Luego ajusta a la décima de segundo.';

  @override
  String get guide3Title => 'Crea una LyricsCard';

  @override
  String get guide3Body =>
      'Elige un fragmento, un fondo y una fuente, y guarda la imagen en la galería o compártela.';

  @override
  String get wsAddLyrics => 'Añadir letras';

  @override
  String get wsSyncSongs => 'Sincronizar';

  @override
  String get lcCreateShort => 'LyricsCard';

  @override
  String get lcCreate => 'Crear una LyricsCard';

  @override
  String get lcTabText => 'Texto';

  @override
  String get lcTabImage => 'Imagen';

  @override
  String get lcTabFont => 'Fuente';

  @override
  String get lcChange => 'Cambiar';

  @override
  String get lcPickSong => 'Canciones con letra';

  @override
  String get lcNoSongs => 'Ninguna canción con letra';

  @override
  String get lcNoSongsBody =>
      'Añade letras desde el Taller para crear una tarjeta.';

  @override
  String get lcSelectHint =>
      'Toca una línea y luego otra para ampliar. Mantén pulsado para ajustar carácter a carácter.';

  @override
  String get lcClear => 'Borrar selección';

  @override
  String get lcTooLong => 'Demasiado largo: 113 caracteres como máximo';

  @override
  String get lcPlaceholder => 'Elige un fragmento de la letra';

  @override
  String get lcContinue => 'Continuar';

  @override
  String get lcArtwork => 'Portada';

  @override
  String get lcGallery => 'Galería';

  @override
  String get lcDim => 'Oscurecer';

  @override
  String get lcBlur => 'Desenfoque';

  @override
  String get lcFormat => 'Formato';

  @override
  String get lcSize => 'Tamaño';

  @override
  String get lcAlign => 'Alineación';

  @override
  String get lcColor => 'Color del texto';

  @override
  String get lcShowInfo => 'Título y artista';

  @override
  String get lcExport => 'Exportar';

  @override
  String get lcSave => 'Guardar en la galería';

  @override
  String get lcShare => 'Compartir';

  @override
  String get lcSaved => 'Tarjeta guardada en la galería';

  @override
  String get lcSaveDenied => 'Acceso al almacenamiento denegado';

  @override
  String get lcError => 'La exportación falló';

  @override
  String get deleteFromDevice => 'Eliminar del teléfono';

  @override
  String get deleteTrackTitle => '¿Eliminar esta canción?';

  @override
  String deleteTrackBody(String name) {
    return '«$name» se eliminará definitivamente del teléfono.';
  }

  @override
  String deleteTracksTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count canciones?',
      one: '¿Eliminar 1 canción?',
    );
    return '$_temp0';
  }

  @override
  String get deleteTracksBody =>
      'Estos archivos se eliminarán definitivamente del teléfono.';

  @override
  String get deleteAlbum => 'Eliminar el álbum';

  @override
  String get deleteAlbumTitle => '¿Eliminar este álbum?';

  @override
  String deleteAlbumBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '«$name» y sus $count canciones se eliminarán definitivamente del teléfono.',
      one: '«$name» y su canción se eliminarán definitivamente del teléfono.',
    );
    return '$_temp0';
  }

  @override
  String deletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones eliminadas',
      one: '1 canción eliminada',
    );
    return '$_temp0';
  }

  @override
  String get deleteError => 'No se pudieron eliminar los archivos.';

  @override
  String get editAlbum => 'Editar el álbum';

  @override
  String get fieldTrackTotal => 'Número de pistas';

  @override
  String get multipleValues => 'Varios valores';

  @override
  String albumEditInfo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Los cambios se escriben en las $count canciones del álbum.',
      one: 'Los cambios se escriben en la canción del álbum.',
    );
    return '$_temp0 Los campos que no toques no cambian.';
  }

  @override
  String albumSaving(int done, int total) {
    return 'Escribiendo $done / $total…';
  }

  @override
  String get albumSaved => 'Álbum actualizado';

  @override
  String albumSavePartial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones no se pudieron modificar',
      one: '1 canción no se pudo modificar',
    );
    return '$_temp0';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Ya está en $name';
  }

  @override
  String skippedDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicados omitidos',
      one: '1 duplicado omitido',
    );
    return '$_temp0';
  }

  @override
  String get inPlaylist => 'Ya está en la playlist';

  @override
  String get select => 'Seleccionar';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get clearSelection => 'Cancelar la selección';

  @override
  String get back5 => 'Retroceder 5 segundos';

  @override
  String get syncSpeed => 'Velocidad de reproducción';

  @override
  String get syncSpeedHint =>
      'Ralentiza la canción para tocar con más precisión: los tiempos siguen siendo exactos.';

  @override
  String get syncLatency => 'Tiempo de reacción';

  @override
  String get syncLatencyHint =>
      'Se resta de cada toque para compensar el retraso entre oír y tocar.';

  @override
  String get syncSetHere => 'Fijar aquí';

  @override
  String get syncSettings => 'Ajustes de sincronización';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones movidas a la papelera',
      one: '1 canción movida a la papelera',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String restoredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones restauradas',
      one: '1 canción restaurada',
    );
    return '$_temp0';
  }

  @override
  String get trash => 'Papelera';

  @override
  String get trashSub => 'Canciones eliminadas, recuperables durante 30 días';

  @override
  String get trashEmptyTitle => 'La papelera está vacía';

  @override
  String get trashEmptyBody =>
      'Las canciones eliminadas se quedan aquí 30 días antes de que el teléfono las borre.';

  @override
  String get trashUnsupported =>
      'La papelera necesita Android 11 o posterior. En este teléfono, eliminar es definitivo.';

  @override
  String trashExpires(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Se borra en $days días',
      one: 'Se borra en 1 día',
      zero: 'Se borra hoy',
    );
    return '$_temp0';
  }

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreAll => 'Restaurar todo';

  @override
  String get emptyTrash => 'Vaciar la papelera';

  @override
  String get deleteForever => 'Eliminar definitivamente';

  @override
  String get emptyTrashTitle => '¿Vaciar la papelera?';

  @override
  String get emptyTrashBody =>
      'Estas canciones se eliminarán definitivamente. No se puede deshacer.';

  @override
  String get addAnyway => 'Añadir igualmente';

  @override
  String removedFromPlaylist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones quitadas',
      one: '1 canción quitada',
    );
    return '$_temp0';
  }

  @override
  String get syncBreak => 'Pausa';

  @override
  String get syncBreakLine => 'Pausa instrumental';

  @override
  String get syncBreakHint =>
      'Marcar el final de la línea que acaba de terminar (pasaje instrumental)';

  @override
  String get syncRemoveBreak => 'Quitar la pausa';

  @override
  String get syncSnap => 'Ajustar a la voz';

  @override
  String get syncSnapAll => 'Ajustar todas';

  @override
  String syncSnapped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count líneas ajustadas',
      one: '1 línea ajustada',
      zero: 'Ninguna línea movida',
    );
    return '$_temp0';
  }

  @override
  String get syncWaveLoading => 'Analizando el sonido…';

  @override
  String get syncWaveHint =>
      'Desliza la onda para mover la línea. El inicio de una voz se ve como una subida.';
}
