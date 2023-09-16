import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class SubCategoryScreen extends StatefulWidget {
  final String categoryId;
  final QuizTypes quizType;
  final String categoryName;
  const SubCategoryScreen({
    Key? key,
    required this.categoryId,
    required this.quizType,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => SubCategoryScreen(
        categoryId: arguments['categoryId'],
        quizType: arguments['quizType'],
        categoryName: arguments['category_name'],
      ),
    );
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  void getSubCategory() {
    Future.delayed(Duration.zero, () {
      context.read<SubCategoryCubit>().fetchSubCategory(
        widget.categoryId,
        context.read<UserDetailsCubit>().getUserId(),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getSubCategory();
  }

  void handleListTileTap(String? id, bool isPlayed) {
    if (widget.quizType == QuizTypes.guessTheWord) {
      Navigator.of(context).pushNamed(Routes.guessTheWord, arguments: {
        "type": "subcategory",
        "typeId": id,
        "isPlayed": isPlayed,
      });
    } else if (widget.quizType == QuizTypes.funAndLearn) {
      Navigator.of(context).pushNamed(Routes.funAndLearnTitle, arguments: {
        "type": "subcategory",
        "typeId": id,
      });
    } else if (widget.quizType == QuizTypes.audioQuestions) {
      Navigator.of(context).pushNamed(Routes.quiz, arguments: {
        "numberOfPlayer": 1,
        "quizType": QuizTypes.audioQuestions,
        "subcategoryId": id,
        "isPlayed": isPlayed,
      });
    } else if (widget.quizType == QuizTypes.mathMania) {
      Navigator.of(context).pushNamed(Routes.quiz, arguments: {
        "numberOfPlayer": 1,
        "quizType": QuizTypes.mathMania,
        "subcategoryId": id,
        "isPlayed": isPlayed,
      });
    }
  }

  Widget _buildSubCategory() {
    return BlocConsumer<SubCategoryCubit, SubCategoryState>(
        bloc: context.read<SubCategoryCubit>(),
        listener: (context, state) {
          if (state is SubCategoryFetchFailure) {
            if (state.errorMessage == unauthorizedAccessCode) {
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
        builder: (context, state) {
          if (state is SubCategoryFetchInProgress ||
              state is SubCategoryInitial) {
            return Center(
              child: CircularProgressContainer(useWhiteLoader: false),
            );
          }
          if (state is SubCategoryFetchFailure) {
            return Center(
              child: ErrorContainer(
                showBackButton: false,
                showErrorImage: true,
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                  convertErrorCodeToLanguageKey(state.errorMessage),
                ),
                onTapRetry: () {
                  getSubCategory();
                },
              ),
            );
          }
          final subCategoryList =
              (state as SubCategoryFetchSuccess).subcategoryList;
          return Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subCategoryList.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 90,
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: ListTile(
                    onTap: () {
                      handleListTileTap(
                        subCategoryList[index].id,
                        subCategoryList[index].isPlayed,
                      );
                    },
                    trailing: Icon(
                      Icons.navigate_next_outlined,
                      size: 40,
                      color: Theme.of(context).backgroundColor,
                    ),
                    title: Text(
                      subCategoryList[index].subcategoryName!,
                      style:
                      TextStyle(color: Theme.of(context).backgroundColor),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(widget.categoryName),
        centerTitle: true,
        leading: CustomBackButton(iconColor: Theme.of(context).primaryColor),
      ),
      body: Stack(
        children: [
          _buildSubCategory(),

          /// Banner Ad
          Align(
            alignment: Alignment.bottomCenter,
            child: BannerAdContainer(),
          ),
        ],
      ),
    );
  }
}
