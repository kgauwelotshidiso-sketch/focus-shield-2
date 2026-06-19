package com.example.focus_shield_android

import android.content.Context
import android.database.sqlite.SQLiteDatabase

data class FocusShieldBlocklistStatus(
    val loaded: Boolean,
    val count: Int,
    val error: String? = null
)

class FocusShieldBlocklistStore(
    private val context: Context
) {
    private val databaseName = "focus_shield.db"
    private val tableName = "blocked_domains"
    private val domainColumn = "domain"

    fun loadDomains(): List<String> {
        val databaseFile = context.getDatabasePath(databaseName)

        if (!databaseFile.exists()) {
            return emptyList()
        }

        val database = SQLiteDatabase.openDatabase(
            databaseFile.path,
            null,
            SQLiteDatabase.OPEN_READONLY
        )

        return try {
            val domains = mutableListOf<String>()

            database.rawQuery(
                "SELECT $domainColumn FROM $tableName ORDER BY $domainColumn",
                null
            ).use { cursor ->
                val domainIndex = cursor.getColumnIndexOrThrow(domainColumn)

                while (cursor.moveToNext()) {
                    val domain = cursor.getString(domainIndex)?.trim().orEmpty()

                    if (domain.isNotEmpty()) {
                        domains.add(domain)
                    }
                }
            }

            domains
        } finally {
            database.close()
        }
    }

    fun status(): FocusShieldBlocklistStatus {
        return try {
            val domains = loadDomains()

            FocusShieldBlocklistStatus(
                loaded = true,
                count = domains.size
            )
        } catch (error: Exception) {
            FocusShieldBlocklistStatus(
                loaded = false,
                count = 0,
                error = error.message
            )
        }
    }
}
