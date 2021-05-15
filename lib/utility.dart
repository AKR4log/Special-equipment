import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getChatTime(BuildContext context, String date) {
  Locale myLocale = Localizations.localeOf(context);
  if (date == null || date.isEmpty) {
    return '';
  }
  String msg = '';
  var dt = DateTime.parse(date).toLocal();

  if (DateTime.now().toLocal().isBefore(dt)) {
    return DateFormat.jm().format(DateTime.parse(date).toLocal()).toString();
  }

  var dur = DateTime.now().toLocal().difference(dt);
  if (dur.inDays > 365) {
    msg = DateFormat.d(myLocale.toString()).add_MMM().add_y().format(dt);
  } else if (dur.inDays > 0) {
    msg =
        DateFormat.E(myLocale.toString()).add_jm().add_d().add_MMM().format(dt);
  } else if (dur.inHours > 0) {
    msg = DateFormat.jm(myLocale.toString()).add_d().add_MMM().format(dt);
  } else if (dur.inMinutes > 0) {
    msg = DateFormat.jm(myLocale.toString()).format(dt);
  } else if (dur.inSeconds > 0) {
    msg = '${dur.inSeconds} s';
  } else {
    msg = 'now';
  }
  return msg;
}

String getTimeMessage(BuildContext context, String date) {
  Locale myLocale = Localizations.localeOf(context);
  if (date == null || date.isEmpty) {
    return '';
  }
  var dt = DateTime.parse(date).toLocal();

  if (DateTime.now().toLocal().isBefore(dt)) {
    return DateFormat.jm().format(DateTime.parse(date).toLocal()).toString();
  }

  return DateFormat.jm(myLocale.toString()).format(dt);
}
