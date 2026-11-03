export 'package:academic_api/academic_api.dart'
    show
        HttpCookieData,
        HttpRequestSpec,
        HttpResponseData,
        HttpTransport,
        HttpTransportException;

export 'http_transport_io.dart'
    if (dart.library.js_interop) 'http_transport_web.dart';
