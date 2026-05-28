package com.example.flutter_reccuring_reminder

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.view.View

class FitVisWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.fit_vis_widget).apply {
                
                val title = widgetData.getString("next_title", "") ?: ""
                val date = widgetData.getString("next_date", "") ?: ""
                val category = widgetData.getString("next_category", "") ?: ""
                val overdue = widgetData.getInt("overdue_count", 0)

                setTextViewText(R.id.next_title, if (title.isEmpty()) "Žádné úkoly" else title)
                setTextViewText(R.id.next_date, date)
                setTextViewText(R.id.next_category, category)

                if (overdue > 0) {
                    setViewVisibility(R.id.overdue_badge, View.VISIBLE)
                    setTextViewText(R.id.overdue_badge, "$overdue po termínu")
                } else {
                    setViewVisibility(R.id.overdue_badge, View.GONE)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
