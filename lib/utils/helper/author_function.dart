String removeHttpsAndCom(String url) {
  String result = url.replaceAll('https://', ''); // Removing "https://"
  result = result.replaceAll('www.', ''); // Removing "www."
  result = result.replaceAll('.com', ''); // Removing ".com"
  return result;
}

String extractDomainName(String url) {
  try {
    final uri = Uri.parse(url);
    String host = uri.host;

    // Retirer "www." si présent
    if (host.startsWith('www.')) {
      host = host.substring(4);
    }

    // Extraire le nom de domaine principal (avant le premier point)
    final parts = host.split('.');
    if (parts.isNotEmpty) {
      return parts[0];
    }

    return host;
  } catch (e) {
    // Fallback si l'URL n'est pas valide
    return _extractDomainFallback(url);
  }
}

String _extractDomainFallback(String url) {
  // Méthode de fallback pour les URLs mal formées
  String result = url
      .replaceAll('https://', '')
      .replaceAll('http://', '')
      .replaceAll('www.', '');

  // Supprimer tout après le premier slash
  final slashIndex = result.indexOf('/');
  if (slashIndex != -1) {
    result = result.substring(0, slashIndex);
  }

  // Extraire le nom avant le premier point
  final dotIndex = result.indexOf('.');
  if (dotIndex != -1) {
    result = result.substring(0, dotIndex);
  }

  return result;
}
