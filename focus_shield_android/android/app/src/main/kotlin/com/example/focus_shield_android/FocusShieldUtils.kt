package com.example.focus_shield_android

fun Any?.focusShieldStatusInt(): Int {
    if (this == null) return 0
    return when (this) {
        is Number -> this.toInt()
        is String -> this.toIntOrNull() ?: 0
        is Boolean -> if (this) 1 else 0
        else -> 0
    }
}

fun Any?.focusShieldStatusLong(): Long {
    if (this == null) return 0L
    return when (this) {
        is Number -> this.toLong()
        is String -> this.toLongOrNull() ?: 0L
        is Boolean -> if (this) 1L else 0L
        else -> 0L
    }
}

fun Any?.focusShieldStatusString(): String {
    return this?.toString() ?: "-"
}
