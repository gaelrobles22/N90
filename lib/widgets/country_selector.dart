import 'package:flutter/material.dart';

class Country {
  final String name;
  final String code;

  const Country({
    required this.name,
    required this.code,
  });

  String get flag {
    return code
        .toUpperCase()
        .runes
        .map(
          (rune) => String.fromCharCode(
        rune + 127397,
      ),
    )
        .join();
  }
}

class CountrySelector extends StatefulWidget {
  final String? selectedCountry;
  final ValueChanged<Country> onSelected;

  const CountrySelector({
    super.key,
    this.selectedCountry,
    required this.onSelected,
  });

  @override
  State<CountrySelector> createState() =>
      _CountrySelectorState();
}

class _CountrySelectorState
    extends State<CountrySelector> {
  final TextEditingController _searchController =
  TextEditingController();

  List<Country> _filteredCountries = [];

  static const List<Country> _countries = [
    Country(name: 'Afganistán', code: 'AF'),
    Country(name: 'Albania', code: 'AL'),
    Country(name: 'Alemania', code: 'DE'),
    Country(name: 'Andorra', code: 'AD'),
    Country(name: 'Angola', code: 'AO'),
    Country(name: 'Antigua y Barbuda', code: 'AG'),
    Country(name: 'Arabia Saudita', code: 'SA'),
    Country(name: 'Argelia', code: 'DZ'),
    Country(name: 'Argentina', code: 'AR'),
    Country(name: 'Armenia', code: 'AM'),
    Country(name: 'Australia', code: 'AU'),
    Country(name: 'Austria', code: 'AT'),
    Country(name: 'Azerbaiyán', code: 'AZ'),

    Country(name: 'Bahamas', code: 'BS'),
    Country(name: 'Barbados', code: 'BB'),
    Country(name: 'Baréin', code: 'BH'),
    Country(name: 'Bangladés', code: 'BD'),
    Country(name: 'Bélgica', code: 'BE'),
    Country(name: 'Belice', code: 'BZ'),
    Country(name: 'Benín', code: 'BJ'),
    Country(name: 'Bielorrusia', code: 'BY'),
    Country(name: 'Bolivia', code: 'BO'),
    Country(name: 'Bosnia y Herzegovina', code: 'BA'),
    Country(name: 'Botsuana', code: 'BW'),
    Country(name: 'Brasil', code: 'BR'),
    Country(name: 'Brunéi', code: 'BN'),
    Country(name: 'Bulgaria', code: 'BG'),
    Country(name: 'Burkina Faso', code: 'BF'),
    Country(name: 'Burundi', code: 'BI'),
    Country(name: 'Bután', code: 'BT'),

    Country(name: 'Cabo Verde', code: 'CV'),
    Country(name: 'Camboya', code: 'KH'),
    Country(name: 'Camerún', code: 'CM'),
    Country(name: 'Canadá', code: 'CA'),
    Country(name: 'Catar', code: 'QA'),
    Country(name: 'Chad', code: 'TD'),
    Country(name: 'Chile', code: 'CL'),
    Country(name: 'China', code: 'CN'),
    Country(name: 'Chipre', code: 'CY'),
    Country(name: 'Colombia', code: 'CO'),
    Country(name: 'Comoras', code: 'KM'),
    Country(name: 'Congo', code: 'CG'),
    Country(name: 'Corea del Norte', code: 'KP'),
    Country(name: 'Corea del Sur', code: 'KR'),
    Country(name: 'Costa Rica', code: 'CR'),
    Country(name: 'Costa de Marfil', code: 'CI'),
    Country(name: 'Croacia', code: 'HR'),
    Country(name: 'Cuba', code: 'CU'),

    Country(name: 'Dinamarca', code: 'DK'),
    Country(name: 'Dominica', code: 'DM'),
    Country(name: 'Ecuador', code: 'EC'),
    Country(name: 'Egipto', code: 'EG'),
    Country(name: 'El Salvador', code: 'SV'),
    Country(name: 'Emiratos Árabes Unidos', code: 'AE'),
    Country(name: 'Eritrea', code: 'ER'),
    Country(name: 'Eslovaquia', code: 'SK'),
    Country(name: 'Eslovenia', code: 'SI'),
    Country(name: 'España', code: 'ES'),
    Country(name: 'Estados Unidos', code: 'US'),
    Country(name: 'Estonia', code: 'EE'),
    Country(name: 'Esuatini', code: 'SZ'),
    Country(name: 'Etiopía', code: 'ET'),

    Country(name: 'Fiji', code: 'FJ'),
    Country(name: 'Filipinas', code: 'PH'),
    Country(name: 'Finlandia', code: 'FI'),
    Country(name: 'Francia', code: 'FR'),

    Country(name: 'Gabón', code: 'GA'),
    Country(name: 'Gambia', code: 'GM'),
    Country(name: 'Georgia', code: 'GE'),
    Country(name: 'Ghana', code: 'GH'),
    Country(name: 'Granada', code: 'GD'),
    Country(name: 'Grecia', code: 'GR'),
    Country(name: 'Guatemala', code: 'GT'),
    Country(name: 'Guinea', code: 'GN'),
    Country(name: 'Guinea-Bisáu', code: 'GW'),
    Country(name: 'Guinea Ecuatorial', code: 'GQ'),
    Country(name: 'Guyana', code: 'GY'),

    Country(name: 'Haití', code: 'HT'),
    Country(name: 'Honduras', code: 'HN'),
    Country(name: 'Hungría', code: 'HU'),

    Country(name: 'India', code: 'IN'),
    Country(name: 'Indonesia', code: 'ID'),
    Country(name: 'Irak', code: 'IQ'),
    Country(name: 'Irán', code: 'IR'),
    Country(name: 'Irlanda', code: 'IE'),
    Country(name: 'Islandia', code: 'IS'),
    Country(name: 'Islas Marshall', code: 'MH'),
    Country(name: 'Islas Salomón', code: 'SB'),
    Country(name: 'Israel', code: 'IL'),
    Country(name: 'Italia', code: 'IT'),

    Country(name: 'Jamaica', code: 'JM'),
    Country(name: 'Japón', code: 'JP'),
    Country(name: 'Jordania', code: 'JO'),

    Country(name: 'Kazajistán', code: 'KZ'),
    Country(name: 'Kenia', code: 'KE'),
    Country(name: 'Kirguistán', code: 'KG'),
    Country(name: 'Kiribati', code: 'KI'),
    Country(name: 'Kuwait', code: 'KW'),

    Country(name: 'Laos', code: 'LA'),
    Country(name: 'Lesoto', code: 'LS'),
    Country(name: 'Letonia', code: 'LV'),
    Country(name: 'Líbano', code: 'LB'),
    Country(name: 'Liberia', code: 'LR'),
    Country(name: 'Libia', code: 'LY'),
    Country(name: 'Liechtenstein', code: 'LI'),
    Country(name: 'Lituania', code: 'LT'),
    Country(name: 'Luxemburgo', code: 'LU'),

    Country(name: 'Madagascar', code: 'MG'),
    Country(name: 'Malasia', code: 'MY'),
    Country(name: 'Malaui', code: 'MW'),
    Country(name: 'Maldivas', code: 'MV'),
    Country(name: 'Malí', code: 'ML'),
    Country(name: 'Malta', code: 'MT'),
    Country(name: 'Marruecos', code: 'MA'),
    Country(name: 'Mauricio', code: 'MU'),
    Country(name: 'Mauritania', code: 'MR'),
    Country(name: 'México', code: 'MX'),
    Country(name: 'Micronesia', code: 'FM'),
    Country(name: 'Moldavia', code: 'MD'),
    Country(name: 'Mónaco', code: 'MC'),
    Country(name: 'Mongolia', code: 'MN'),
    Country(name: 'Montenegro', code: 'ME'),
    Country(name: 'Mozambique', code: 'MZ'),
    Country(name: 'Myanmar', code: 'MM'),

    Country(name: 'Namibia', code: 'NA'),
    Country(name: 'Nauru', code: 'NR'),
    Country(name: 'Nepal', code: 'NP'),
    Country(name: 'Nicaragua', code: 'NI'),
    Country(name: 'Níger', code: 'NE'),
    Country(name: 'Nigeria', code: 'NG'),
    Country(name: 'Noruega', code: 'NO'),
    Country(name: 'Nueva Zelanda', code: 'NZ'),

    Country(name: 'Omán', code: 'OM'),

    Country(name: 'Países Bajos', code: 'NL'),
    Country(name: 'Pakistán', code: 'PK'),
    Country(name: 'Palaos', code: 'PW'),
    Country(name: 'Panamá', code: 'PA'),
    Country(name: 'Papúa Nueva Guinea', code: 'PG'),
    Country(name: 'Paraguay', code: 'PY'),
    Country(name: 'Perú', code: 'PE'),
    Country(name: 'Polonia', code: 'PL'),
    Country(name: 'Portugal', code: 'PT'),

    Country(name: 'Reino Unido', code: 'GB'),
    Country(name: 'República Centroafricana', code: 'CF'),
    Country(name: 'República Checa', code: 'CZ'),
    Country(
      name: 'República Democrática del Congo',
      code: 'CD',
    ),
    Country(name: 'República Dominicana', code: 'DO'),
    Country(name: 'Ruanda', code: 'RW'),
    Country(name: 'Rumania', code: 'RO'),
    Country(name: 'Rusia', code: 'RU'),

    Country(name: 'Samoa', code: 'WS'),
    Country(name: 'San Cristóbal y Nieves', code: 'KN'),
    Country(name: 'San Marino', code: 'SM'),
    Country(
      name: 'San Vicente y las Granadinas',
      code: 'VC',
    ),
    Country(name: 'Santa Lucía', code: 'LC'),
    Country(
      name: 'Santo Tomé y Príncipe',
      code: 'ST',
    ),
    Country(name: 'Senegal', code: 'SN'),
    Country(name: 'Serbia', code: 'RS'),
    Country(name: 'Seychelles', code: 'SC'),
    Country(name: 'Sierra Leona', code: 'SL'),
    Country(name: 'Singapur', code: 'SG'),
    Country(name: 'Siria', code: 'SY'),
    Country(name: 'Somalia', code: 'SO'),
    Country(name: 'Sri Lanka', code: 'LK'),
    Country(name: 'Sudáfrica', code: 'ZA'),
    Country(name: 'Sudán', code: 'SD'),
    Country(name: 'Sudán del Sur', code: 'SS'),
    Country(name: 'Suecia', code: 'SE'),
    Country(name: 'Suiza', code: 'CH'),
    Country(name: 'Surinam', code: 'SR'),

    Country(name: 'Tailandia', code: 'TH'),
    Country(name: 'Tanzania', code: 'TZ'),
    Country(name: 'Tayikistán', code: 'TJ'),
    Country(name: 'Timor-Leste', code: 'TL'),
    Country(name: 'Togo', code: 'TG'),
    Country(name: 'Tonga', code: 'TO'),
    Country(
      name: 'Trinidad y Tobago',
      code: 'TT',
    ),
    Country(name: 'Túnez', code: 'TN'),
    Country(name: 'Turkmenistán', code: 'TM'),
    Country(name: 'Turquía', code: 'TR'),
    Country(name: 'Tuvalu', code: 'TV'),

    Country(name: 'Ucrania', code: 'UA'),
    Country(name: 'Uganda', code: 'UG'),
    Country(name: 'Uruguay', code: 'UY'),
    Country(name: 'Uzbekistán', code: 'UZ'),

    Country(name: 'Vanuatu', code: 'VU'),
    Country(name: 'Vaticano', code: 'VA'),
    Country(name: 'Venezuela', code: 'VE'),
    Country(name: 'Vietnam', code: 'VN'),

    Country(name: 'Yemen', code: 'YE'),
    Country(name: 'Yibuti', code: 'DJ'),

    Country(name: 'Zambia', code: 'ZM'),
    Country(name: 'Zimbabue', code: 'ZW'),
  ];

  @override
  void initState() {
    super.initState();

    _filteredCountries =
    List<Country>.from(_countries);

    _searchController.addListener(
      _filterCountries,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final search =
    _normalize(_searchController.text);

    setState(() {
      if (search.isEmpty) {
        _filteredCountries =
        List<Country>.from(_countries);
      } else {
        _filteredCountries =
            _countries.where((country) {
              final name =
              _normalize(country.name);

              return name.contains(search);
            }).toList();
      }
    });
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedCountry;

    return InkWell(
      onTap: _openCountryDialog,
      borderRadius:
      BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius:
          BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              Text(
                _getFlag(selected),
                style:
                const TextStyle(
                  fontSize: 21,
                ),
              ),
              const SizedBox(width: 12),
            ],

            Expanded(
              child: Text(
                selected ??
                    'Selecciona tu país',
                style: TextStyle(
                  color: selected == null
                      ? Colors.white54
                      : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF9DFF21),
            ),
          ],
        ),
      ),
    );
  }

  String _getFlag(String countryName) {
    final country = _countries.firstWhere(
          (country) =>
      country.name == countryName,
      orElse: () => const Country(
        name: '',
        code: '',
      ),
    );

    return country.flag;
  }

  Future<void> _openCountryDialog() async {
    _searchController.clear();

    final selected =
    await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      builder: (context) {
        return _CountryPickerSheet(
          countries:
          _filteredCountries,
          searchController:
          _searchController,
          selectedCountry:
          widget.selectedCountry,
          onSearchChanged:
          _filterCountries,
        );
      },
    );

    if (selected != null) {
      widget.onSelected(selected);
    }
  }
}

// ==================================================================
// COUNTRY PICKER SHEET
// ==================================================================

class _CountryPickerSheet
    extends StatefulWidget {
  final List<Country> countries;
  final TextEditingController searchController;
  final String? selectedCountry;
  final VoidCallback onSearchChanged;

  const _CountryPickerSheet({
    required this.countries,
    required this.searchController,
    required this.selectedCountry,
    required this.onSearchChanged,
  });

  @override
  State<_CountryPickerSheet> createState() =>
      _CountryPickerSheetState();
}

class _CountryPickerSheetState
    extends State<_CountryPickerSheet> {
  late List<Country> _countries;

  @override
  void initState() {
    super.initState();

    _countries =
    List<Country>.from(
      widget.countries,
    );

    widget.searchController.addListener(
      _updateList,
    );
  }

  @override
  void dispose() {
    widget.searchController.removeListener(
      _updateList,
    );
    super.dispose();
  }

  void _updateList() {
    final search =
    _normalize(
      widget.searchController.text,
    );

    setState(() {
      if (search.isEmpty) {
        _countries =
        List<Country>.from(
          _CountrySelectorState
              ._countries,
        );
      } else {
        _countries =
            _CountrySelectorState
                ._countries
                .where(
                  (country) {
                return _normalize(
                  country.name,
                ).contains(search);
              },
            ).toList();
      }
    });
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
      MediaQuery.of(context).size.height *
          0.82,
      decoration:
      const BoxDecoration(
        color: Color(0xFF151515),
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------
            // HANDLE
            // ----------------------------------------------------

            const SizedBox(height: 10),

            Container(
              width: 45,
              height: 4,
              decoration:
              BoxDecoration(
                color: Colors.white30,
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ----------------------------------------------------
            // HEADER
            // ----------------------------------------------------

            const Padding(
              padding:
              EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Align(
                alignment:
                Alignment.centerLeft,
                child: Text(
                  'Selecciona tu país',
                  style: TextStyle(
                    color:
                    Colors.white,
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ----------------------------------------------------
            // SEARCH
            // ----------------------------------------------------

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: TextField(
                controller:
                widget.searchController,
                autofocus: true,
                style:
                const TextStyle(
                  color: Colors.white,
                ),
                decoration:
                InputDecoration(
                  hintText:
                  'Buscar país...',
                  hintStyle:
                  const TextStyle(
                    color:
                    Colors.white54,
                  ),
                  prefixIcon:
                  const Icon(
                    Icons.search,
                    color:
                    Color(0xFF9DFF21),
                  ),
                  suffixIcon:
                  widget.searchController
                      .text
                      .isNotEmpty
                      ? IconButton(
                    icon:
                    const Icon(
                      Icons.clear,
                      color:
                      Colors.white54,
                    ),
                    onPressed: () {
                      widget
                          .searchController
                          .clear();
                    },
                  )
                      : null,
                  filled: true,
                  fillColor:
                  Colors.white10,
                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                    borderSide:
                    BorderSide.none,
                  ),
                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                    borderSide:
                    const BorderSide(
                      color:
                      Color(0xFF9DFF21),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ----------------------------------------------------
            // RESULTS
            // ----------------------------------------------------

            Expanded(
              child: _countries.isEmpty
                  ? const Center(
                child: Text(
                  'No se encontró el país.',
                  style: TextStyle(
                    color:
                    Colors.white70,
                    fontSize: 15,
                  ),
                ),
              )
                  : ListView.builder(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,
                itemCount:
                _countries.length,
                itemBuilder:
                    (context, index) {
                  final country =
                  _countries[index];

                  final isSelected =
                      country.name ==
                          widget
                              .selectedCountry;

                  return ListTile(
                    contentPadding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    leading: Text(
                      country.flag,
                      style:
                      const TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    title: Text(
                      country.name,
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    trailing:
                    isSelected
                        ? const Icon(
                      Icons.check,
                      color:
                      Color(
                        0xFF9DFF21,
                      ),
                    )
                        : null,
                    onTap: () {
                      Navigator.pop(
                        context,
                        country,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}