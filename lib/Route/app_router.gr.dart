// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AnalysisPage]
class AnalysisRoute extends PageRouteInfo<void> {
  const AnalysisRoute({List<PageRouteInfo>? children})
    : super(AnalysisRoute.name, initialChildren: children);

  static const String name = 'AnalysisRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AnalysisPage();
    },
  );
}

/// generated route for
/// [CalendarPage]
class CalendarRoute extends PageRouteInfo<void> {
  const CalendarRoute({List<PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CalendarPage();
    },
  );
}

/// generated route for
/// [CategoryPage]
class CategoryRoute extends PageRouteInfo<void> {
  const CategoryRoute({List<PageRouteInfo>? children})
    : super(CategoryRoute.name, initialChildren: children);

  static const String name = 'CategoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CategoryPage();
    },
  );
}

/// generated route for
/// [CategoryTemplatePage]
class CategoryTemplateRoute extends PageRouteInfo<CategoryTemplateRouteArgs> {
  CategoryTemplateRoute({
    Key? key,
    required String categoryName,
    required String categoryIcon,
    List<PageRouteInfo>? children,
  }) : super(
         CategoryTemplateRoute.name,
         args: CategoryTemplateRouteArgs(
           key: key,
           categoryName: categoryName,
           categoryIcon: categoryIcon,
         ),
         rawPathParams: {
           'categoryName': categoryName,
           'categoryIcon': categoryIcon,
         },
         initialChildren: children,
       );

  static const String name = 'CategoryTemplateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CategoryTemplateRouteArgs>(
        orElse:
            () => CategoryTemplateRouteArgs(
              categoryName: pathParams.getString('categoryName'),
              categoryIcon: pathParams.getString('categoryIcon'),
            ),
      );
      return CategoryTemplatePage(
        key: args.key,
        categoryName: args.categoryName,
        categoryIcon: args.categoryIcon,
      );
    },
  );
}

class CategoryTemplateRouteArgs {
  const CategoryTemplateRouteArgs({
    this.key,
    required this.categoryName,
    required this.categoryIcon,
  });

  final Key? key;

  final String categoryName;

  final String categoryIcon;

  @override
  String toString() {
    return 'CategoryTemplateRouteArgs{key: $key, categoryName: $categoryName, categoryIcon: $categoryIcon}';
  }
}

/// generated route for
/// [ForgotPasswordPage]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MainContainerPage]
class MainContainerRoute extends PageRouteInfo<void> {
  const MainContainerRoute({List<PageRouteInfo>? children})
    : super(MainContainerRoute.name, initialChildren: children);

  static const String name = 'MainContainerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainContainerPage();
    },
  );
}

/// generated route for
/// [NotificationPage]
class NotificationRoute extends PageRouteInfo<void> {
  const NotificationRoute({List<PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationPage();
    },
  );
}

/// generated route for
/// [QuickAnalysisPage]
class QuickAnalysisRoute extends PageRouteInfo<void> {
  const QuickAnalysisRoute({List<PageRouteInfo>? children})
    : super(QuickAnalysisRoute.name, initialChildren: children);

  static const String name = 'QuickAnalysisRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const QuickAnalysisPage();
    },
  );
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchPage();
    },
  );
}

/// generated route for
/// [SignupPage]
class SignupRoute extends PageRouteInfo<void> {
  const SignupRoute({List<PageRouteInfo>? children})
    : super(SignupRoute.name, initialChildren: children);

  static const String name = 'SignupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignupPage();
    },
  );
}

/// generated route for
/// [TransactionsPage]
class TransactionsRoute extends PageRouteInfo<void> {
  const TransactionsRoute({List<PageRouteInfo>? children})
    : super(TransactionsRoute.name, initialChildren: children);

  static const String name = 'TransactionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TransactionsPage();
    },
  );
}
