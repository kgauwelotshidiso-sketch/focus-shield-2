package com.example.focus_shield_android

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView

class FocusShieldInterventionActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val domain = intent.getStringExtra("phase6_accessibility_domain") ?: "blocked site"
        val category = intent.getStringExtra("phase6_accessibility_category") ?: "risk"
        val decision = intent.getStringExtra("phase6_accessibility_decision") ?: "blocked"
        val score = intent.getIntExtra("phase6_accessibility_score", 0)

        title = "Focus Shield Intervention"

        val scrollView = ScrollView(this)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(42, 56, 42, 56)
            setBackgroundColor(Color.rgb(3, 7, 24))
        }

        root.addView(
            titleText("Temptation Detected")
        )

        root.addView(
            bodyText("Focus Shield interrupted a risky website before it pulled you away from your goals.")
        )

        root.addView(
            infoCard(
                "Blocked site",
                "Domain: $domain\nDecision: $decision\nCategory: $category\nRisk score: $score/100"
            )
        )

        root.addView(
            infoCard(
                "Return to your standard",
                "I pause, I listen, and I follow my dreams.\n\nThis is the moment where discipline wins."
            )
        )

        root.addView(
            actionButton("Open Focus Shield") {
                openMainApp()
            }
        )

        root.addView(
            actionButton("Close Intervention") {
                finish()
            }
        )

        scrollView.addView(root)
        setContentView(scrollView)
    }

    private fun titleText(text: String): TextView {
        return TextView(this).apply {
            this.text = text
            textSize = 32f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, 0, 0, 22)
        }
    }

    private fun bodyText(text: String): TextView {
        return TextView(this).apply {
            this.text = text
            textSize = 18f
            setTextColor(Color.rgb(220, 230, 245))
            setPadding(0, 0, 0, 28)
        }
    }

    private fun infoCard(title: String, body: String): LinearLayout {
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(28, 28, 28, 28)
            background = roundedBorder(
                fill = Color.rgb(10, 20, 45),
                stroke = Color.rgb(37, 99, 235)
            )
        }

        val titleView = TextView(this).apply {
            text = title
            textSize = 18f
            setTextColor(Color.WHITE)
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, 0, 0, 12)
        }

        val bodyView = TextView(this).apply {
            text = body
            textSize = 16f
            setTextColor(Color.rgb(220, 230, 245))
        }

        card.addView(titleView)
        card.addView(bodyView)

        val params = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply {
            setMargins(0, 0, 0, 22)
        }

        card.layoutParams = params
        return card
    }

    private fun actionButton(label: String, action: () -> Unit): Button {
        return Button(this).apply {
            text = label
            textSize = 16f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.rgb(3, 7, 24))
            background = roundedFill(Color.rgb(34, 197, 94))
            setPadding(18, 18, 18, 18)
            gravity = Gravity.CENTER
            setOnClickListener { action() }

            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 8, 0, 16)
            }
        }
    }

    private fun roundedBorder(fill: Int, stroke: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = 28f
            setColor(fill)
            setStroke(2, stroke)
        }
    }

    private fun roundedFill(fill: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = 28f
            setColor(fill)
        }
    }

    private fun openMainApp() {
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        startActivity(intent)
        finish()
    }
}
