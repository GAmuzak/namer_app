// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var themeData = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 83, 254, 237)),
          scaffoldBackgroundColor: Color.fromARGB(95, 100, 100, 100),
          );
    var materialApp = MaterialApp(
        title: 'Namer App',
        theme: themeData,
        home: MyHomePage(),
        );
    var changeNotifierProvider = ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: materialApp,
      );
    return changeNotifierProvider;
  }
}

class MyAppState extends ChangeNotifier {
  var currentWordPair = WordPair.random();
  var previousWordPair = WordPair.random();
  var secondPairGenerated = false;

  void changeWordPair(){
    previousWordPair = currentWordPair;
    currentWordPair = WordPair.random();
    if(!secondPairGenerated) secondPairGenerated = true;
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite(){
    if(favorites.contains(currentWordPair)){favorites.remove(currentWordPair);}
    else {favorites.add(currentWordPair);}
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavouritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    var scaffold = LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 900,
                  backgroundColor: Color.fromARGB(100, 182, 182, 182),
                  // extended: false,
                  destinations: [
                    railIcon(theme, "Home", Icons.home),
                    railIcon(theme, "Favourites", Icons.favorite),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                  child: page,
                  
              ),
            ],
          ),
        );
      }
    );
    return scaffold;
  }

  NavigationRailDestination railIcon(ThemeData theme, String text, IconData icon) {
    var navigationRailDestination = NavigationRailDestination(
      icon: Icon(icon, color: theme.colorScheme.onBackground),
      label: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    return navigationRailDestination;
  }
}

class FavouritesPage extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();
    var favWords = appState.favorites;
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(height: 20,),
        Card(
          color: theme.colorScheme.inversePrimary,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Favourite Words List",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: favWords.length,
          itemBuilder: (context, index){
          return ListTile(
            title: FavWord(favWords: favWords, index: index,)
            );
          }
        )
      ],
    );
  }
}

class FavWord extends StatelessWidget {
  const FavWord({
    super.key,
    required this.favWords,
    required this.index,
  });

  final List<WordPair> favWords;
  final int index;
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.favorite, color: theme.colorScheme.inversePrimary),
      title: Text(
        favWords[index].asPascalCase,
        style: TextStyle(
          color: Colors.white
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.currentWordPair;
    var prevPair = appState.previousWordPair;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onTertiary, 
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Random Word Pair Generator", style: style, ),
          SizedBox(height: 20),
          BigCard(pair: pair),
          SizedBox(height: 10),
          SmolCard(prevPair: prevPair, appState: appState,),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LikeButton(appState: appState, icon: icon),
              SizedBox(width: 10),
              GenerateButton(appState: appState),
            ],
          ),
        ],
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.appState,
    required this.icon,
  });

  final MyAppState appState;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        appState.toggleFavorite();
      },
      icon: Icon(icon),
      label: Text('Like'),
    );
  }
}

class GenerateButton extends StatelessWidget {
  const GenerateButton({
    super.key,
    required this.appState,
  });

  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        appState.changeWordPair();
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Text('Generate New', textAlign: TextAlign.center,),
        
      ),
    );
  }
}

class BigCard extends StatelessWidget {

  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: Colors.black, 
    );


    return Card(
      color: theme.colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asPascalCase, 
          style: style,
          semanticsLabel: "${pair.first} + ${pair.second}",
        ),
      ),
    );
  }
}

class SmolCard extends StatelessWidget {
  const SmolCard({
    super.key,
    required this.prevPair,
    required this.appState,
  });

  final WordPair prevPair;
  final MyAppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineSmall!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    Text textData = Text(
      'Prev: ${prevPair.asPascalCase}',
      style: style,
      semanticsLabel: "${prevPair.first} + ${prevPair.second}",
      );
    if(!appState.secondPairGenerated){
      textData = Text("Prev: None", style: style,);
    }

    var card = Card(
      color: theme.colorScheme.secondary,
      elevation: style.height,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: textData,
      ),
    );
    return card;
  }
}