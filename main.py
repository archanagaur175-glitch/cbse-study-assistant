import os
import re
from kivy.clock import Clock
from kivy.uix.scrollview import ScrollView
from kivy.uix.screenmanager import ScreenManager, SlideTransition
from kivy.metrics import dp, sp
from kivy.core.window import Window
from kivy.lang import Builder
from kivy.properties import ObjectProperty

from kivymd.app import MDApp
from kivymd.uix.card import MDCard
from kivymd.uix.button import MDRaisedButton, MDFlatButton
from kivymd.uix.textfield import MDTextField
from kivymd.uix.label import MDLabel, MDIcon
from kivymd.uix.screen import MDScreen
from kivymd.uix.bottomnavigation import MDBottomNavigation, MDBottomNavigationItem
from kivymd.uix.boxlayout import MDBoxLayout
from kivymd.uix.toolbar import MDTopAppBar


from data_loader import init_data_paths, load_chapters, load_profile, save_profile, profile_exists, DEFAULT_PROFILE
from recommender import (
    calculate_recovery_time, search_chapters, get_daily_recommendation,
    get_recommendations, get_priority_topics
)


KV = """
<OnboardingScreen>:
    ScrollView:
        MDBoxLayout:
            orientation: "vertical"
            size_hint_y: None
            height: self.minimum_height
            padding: dp(24)
            spacing: dp(16)
            MDBoxLayout:
                orientation: "vertical"
                size_hint_y: None
                height: self.minimum_height
                spacing: dp(4)
                padding: dp(16)
                MDIcon:
                    icon: "school"
                    icon_size: dp(56)
                    pos_hint: {"center_x": 0.5}
                    theme_text_color: "Custom"
                    text_color: 0.678, 0.549, 0.988, 1
                MDLabel:
                    text: "CBSE Study Assistant"
                    font_style: "H5"
                    halign: "center"
                    theme_text_color: "Primary"
                    bold: True
                    size_hint_y: None
                    height: self.texture_size[1]
                MDLabel:
                    text: "Personalize your learning journey"
                    font_style: "Body1"
                    halign: "center"
                    theme_text_color: "Secondary"
                    size_hint_y: None
                    height: self.texture_size[1]
            MDCard:
                id: setup_card
                orientation: "vertical"
                size_hint_y: None
                height: self.minimum_height
                padding: dp(20)
                spacing: dp(16)
                elevation: 4
                radius: dp(16)
                md_bg_color: 0.18, 0.18, 0.18, 1
                MDLabel:
                    text: "Setup Your Profile"
                    font_style: "H6"
                    halign: "center"
                    theme_text_color: "Primary"
                    size_hint_y: None
                    height: self.texture_size[1]
                MDBoxLayout:
                    orientation: "vertical"
                    size_hint_y: None
                    height: self.minimum_height
                    spacing: dp(4)
                    MDLabel:
                        text: "What should we call you?"
                        font_style: "Caption"
                        theme_text_color: "Secondary"
                        size_hint_y: None
                        height: self.texture_size[1]
                    MDTextField:
                        id: name_input
                        hint_text: "Enter your name"
                        mode: "fill"
                        size_hint_x: 1
                MDBoxLayout:
                    orientation: "vertical"
                    size_hint_y: None
                    height: self.minimum_height
                    spacing: dp(4)
                    MDLabel:
                        text: "Exam Goal"
                        font_style: "Caption"
                        theme_text_color: "Secondary"
                        size_hint_y: None
                        height: self.texture_size[1]
                    MDBoxLayout:
                        id: goal_buttons
                        orientation: "horizontal"
                        size_hint_y: None
                        height: dp(40)
                        spacing: dp(8)
                MDBoxLayout:
                    orientation: "vertical"
                    size_hint_y: None
                    height: self.minimum_height
                    spacing: dp(4)
                    MDLabel:
                        text: "Daily Study Time"
                        font_style: "Caption"
                        theme_text_color: "Secondary"
                        size_hint_y: None
                        height: self.texture_size[1]
                    MDBoxLayout:
                        id: time_buttons
                        orientation: "horizontal"
                        size_hint_y: None
                        height: dp(40)
                        spacing: dp(8)
                MDBoxLayout:
                    orientation: "vertical"
                    size_hint_y: None
                    height: self.minimum_height
                    spacing: dp(4)
                    MDLabel:
                        text: "Study Style"
                        font_style: "Caption"
                        theme_text_color: "Secondary"
                        size_hint_y: None
                        height: self.texture_size[1]
                    MDBoxLayout:
                        id: difficulty_buttons
                        orientation: "horizontal"
                        size_hint_y: None
                        height: dp(40)
                        spacing: dp(8)
                MDBoxLayout:
                    orientation: "vertical"
                    size_hint_y: None
                    height: self.minimum_height
                    spacing: dp(4)
                    MDLabel:
                        text: "Note Length"
                        font_style: "Caption"
                        theme_text_color: "Secondary"
                        size_hint_y: None
                        height: self.texture_size[1]
                    MDBoxLayout:
                        id: note_buttons
                        orientation: "horizontal"
                        size_hint_y: None
                        height: dp(40)
                        spacing: dp(8)
                MDBoxLayout:
                    orientation: "vertical"
                    size_hint_y: None
                    height: self.minimum_height
                    spacing: dp(4)
                    MDLabel:
                        text: "Weak Subjects (comma separated)"
                        font_style: "Caption"
                        theme_text_color: "Secondary"
                        size_hint_y: None
                        height: self.texture_size[1]
                    MDTextField:
                        id: weak_input
                        hint_text: "e.g. Physics, Chemistry"
                        mode: "fill"
                        size_hint_x: 1
                MDRaisedButton:
                    text: "Get Started"
                    size_hint_x: 1
                    size_hint_y: None
                    height: dp(52)
                    on_release: app.save_onboarding()
                    pos_hint: {"center_x": 0.5}
                    md_bg_color: 0.678, 0.549, 0.988, 1

<MainScreen>:
    MDBottomNavigation:
        id: bottom_nav
        panel_color: 0.12, 0.12, 0.12, 1
        selected_color_background: 0.18, 0.18, 0.18, 1
        text_color_active: 0.678, 0.549, 0.988, 1
        MDBottomNavigationItem:
            name: "home_tab"
            text: "Home"
            icon: "home"
            ScrollView:
                id: home_scroll
                do_scroll_x: False
                bar_width: dp(2)
                MDBoxLayout:
                    id: home_box
                    orientation: "vertical"
                    size_hint_y: None
                    height: self.minimum_height
                    padding: dp(16)
                    spacing: dp(12)
        MDBottomNavigationItem:
            name: "search_tab"
            text: "Search"
            icon: "magnify"
            MDBoxLayout:
                orientation: "vertical"
                MDBoxLayout:
                    orientation: "vertical"
                    size_hint_y: None
                    height: self.minimum_height
                    padding: [dp(16), dp(12), dp(16), dp(4)]
                    spacing: dp(8)
                    md_bg_color: 0.12, 0.12, 0.12, 1
                    MDTextField:
                        id: search_input
                        hint_text: "Search chapters by name or subject..."
                        mode: "fill"
                        size_hint_x: 1
                        on_text_validate: app.perform_search()
                    MDBoxLayout:
                        orientation: "horizontal"
                        size_hint_y: None
                        height: dp(44)
                        spacing: dp(12)
                        MDRaisedButton:
                            text: "Search"
                            size_hint_x: 0.5
                            on_release: app.perform_search()
                            md_bg_color: 0.678, 0.549, 0.988, 1
                        MDFlatButton:
                            text: "Clear"
                            size_hint_x: 0.5
                            on_release: app.clear_search()
                ScrollView:
                    do_scroll_x: False
                    bar_width: dp(2)
                    MDBoxLayout:
                        id: search_results
                        orientation: "vertical"
                        size_hint_y: None
                        height: self.minimum_height
                        padding: [dp(16), dp(4), dp(16), dp(16)]
                        spacing: dp(12)
        MDBottomNavigationItem:
            name: "profile_tab"
            text: "Profile"
            icon: "account"
            ScrollView:
                do_scroll_x: False
                bar_width: dp(2)
                MDBoxLayout:
                    id: profile_box
                    orientation: "vertical"
                    size_hint_y: None
                    height: self.minimum_height
                    padding: dp(16)
                    spacing: dp(12)

<ChapterDetailScreen>:
    MDBoxLayout:
        orientation: "vertical"
        MDTopAppBar:
            id: detail_toolbar
            title: "Chapter Details"
            left_action_items: [["arrow-left", lambda x: app.go_home()]]
            elevation: 2
        ScrollView:
            do_scroll_x: False
            bar_width: dp(2)
            MDBoxLayout:
                id: detail_box
                orientation: "vertical"
                size_hint_y: None
                height: self.minimum_height
                padding: dp(16)
                spacing: dp(12)
"""

Builder.load_string(KV)

ACCENT = [0.678, 0.549, 0.988, 1]
BG_DARK = [0.09, 0.09, 0.09, 1]
BG_NORMAL = [0.16, 0.16, 0.16, 1]
BG_LIGHT = [0.22, 0.22, 0.22, 1]
WHITE = [1, 1, 1, 1]
TEXT_SECONDARY = [0.7, 0.7, 0.7, 1]


class OnboardingScreen(MDScreen):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._goal_buttons = []
        self._time_buttons = []
        self._diff_buttons = []
        self._note_buttons = []
        self.selected_goal = "boards"
        self.selected_time = "1 hour"
        self.selected_difficulty = "medium"
        self.selected_note = "medium"
        Clock.schedule_once(self._build_selectors, 0)

    def _build_selectors(self, dt):
        goals = [
            ("boards", "Boards"),
            ("competitive", "Competitive"),
            ("jee", "JEE"),
            ("neet", "NEET"),
        ]
        times = [
            ("30 min", "30m"),
            ("1 hour", "1h"),
            ("2 hours", "2h"),
            ("3+ hours", "3h+"),
        ]
        diffs = [
            ("easy", "Easy"),
            ("medium", "Medium"),
            ("hard", "Hard"),
        ]
        notes = [
            ("short", "Short"),
            ("medium", "Medium"),
            ("detailed", "Detailed"),
        ]

        for val, label in goals:
            btn = MDFlatButton(
                text=label,
                size_hint_x=1,
                on_release=lambda x, v=val: self._select_goal(v),
            )
            self.ids.goal_buttons.add_widget(btn)
            self._goal_buttons.append(btn)

        for val, label in times:
            btn = MDFlatButton(
                text=label,
                size_hint_x=1,
                on_release=lambda x, v=val: self._select_time(v),
            )
            self.ids.time_buttons.add_widget(btn)
            self._time_buttons.append(btn)

        for val, label in diffs:
            btn = MDFlatButton(
                text=label,
                size_hint_x=1,
                on_release=lambda x, v=val: self._select_difficulty(v),
            )
            self.ids.difficulty_buttons.add_widget(btn)
            self._diff_buttons.append(btn)

        for val, label in notes:
            btn = MDFlatButton(
                text=label,
                size_hint_x=1,
                on_release=lambda x, v=val: self._select_note(v),
            )
            self.ids.note_buttons.add_widget(btn)
            self._note_buttons.append(btn)

        self._refresh_selectors()

    def _select_goal(self, val):
        self.selected_goal = val
        self._refresh_selectors()

    def _select_time(self, val):
        self.selected_time = val
        self._refresh_selectors()

    def _select_difficulty(self, val):
        self.selected_difficulty = val
        self._refresh_selectors()

    def _select_note(self, val):
        self.selected_note = val
        self._refresh_selectors()

    def _refresh_selectors(self):
        sets = [
            (self._goal_buttons, ["boards", "competitive", "jee", "neet"], self.selected_goal),
            (self._time_buttons, ["30 min", "1 hour", "2 hours", "3+ hours"], self.selected_time),
            (self._diff_buttons, ["easy", "medium", "hard"], self.selected_difficulty),
            (self._note_buttons, ["short", "medium", "detailed"], self.selected_note),
        ]
        for btns, vals, sel in sets:
            for btn, val in zip(btns, vals):
                if val == sel:
                    btn.md_bg_color = ACCENT
                    btn.theme_text_color = "Custom"
                    btn.text_color = WHITE
                else:
                    btn.md_bg_color = [0, 0, 0, 0]
                    btn.theme_text_color = "Primary"

    def get_profile_data(self):
        name = self.ids.name_input.text.strip()
        weak = self.ids.weak_input.text.strip()
        weak_list = [s.strip() for s in weak.split(",") if s.strip()] if weak else []
        return {
            "name": name or "Student",
            "exam_goal": self.selected_goal,
            "daily_study_time": self.selected_time,
            "difficulty_preference": self.selected_difficulty,
            "note_length_preference": self.selected_note,
            "favorite_subjects": [],
            "weak_subjects": weak_list,
            "chapter_order_preference": "weightage",
        }


class MainScreen(MDScreen):
    def on_enter(self):
        app = MDApp.get_running_app()
        app.build_home_dashboard()


class ChapterDetailScreen(MDScreen):
    def show_chapter(self, chapter):
        app = MDApp.get_running_app()
        app.build_chapter_detail(chapter)


class CBSEApp(MDApp):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.chapters = []
        self.profile = None
        self._settings_goal_btns = []
        self._settings_save_name = None
        self._settings_save_weak = None
        self._settings_save_fav = None

    def build(self):
        self.title = "CBSE Study Assistant"
        self.theme_cls.primary_palette = "DeepPurple"
        self.theme_cls.theme_style = "Dark"

        init_data_paths(self)

        self.chapters = load_chapters()
        self.profile = load_profile()

        sm = ScreenManager(transition=SlideTransition(duration=0.3))
        sm.add_widget(OnboardingScreen(name="onboarding"))
        sm.add_widget(MainScreen(name="main"))
        sm.add_widget(ChapterDetailScreen(name="chapter_detail"))

        if self.profile and self.profile.get("name"):
            sm.current = "main"
        else:
            sm.current = "onboarding"

        Clock.schedule_once(self._fix_window, 0.2)
        Window.bind(size=self._on_window_size)

        return sm

    def _fix_window(self, dt):
        Window.size = Window.system_size
        if self.root:
            self.root.size = Window.size

    def _on_window_size(self, window, size):
        if self.root:
            self.root.size = size

    def save_onboarding(self):
        onboarding = self.root.get_screen("onboarding")
        profile = onboarding.get_profile_data()
        save_profile(profile)
        self.profile = profile
        self.root.current = "main"
        main_screen = self.root.get_screen("main")
        main_screen.on_enter()

    def go_home(self):
        self.root.current = "main"

    def build_home_dashboard(self):
        main_screen = self.root.get_screen("main")
        home_box = main_screen.ids.home_box
        home_box.clear_widgets()

        if not self.chapters:
            card = self._make_card(
                title="No Data",
                subtitle="Check cbse_chapters.csv",
            )
            home_box.add_widget(card)
            return

        profile = self.profile or DEFAULT_PROFILE
        greeting = profile.get("name", "Student")
        goal = profile.get("exam_goal", "boards").title()
        greeting_card = MDCard(
            orientation="vertical",
            size_hint_y=None,
            height=dp(100),
            padding=dp(20),
            spacing=dp(4),
            elevation=4,
            radius=dp(16),
            md_bg_color=BG_LIGHT,
        )
        greeting_card.add_widget(MDLabel(
            text=f"Hello, {greeting}!",
            font_style="H5",
            theme_text_color="Primary",
            bold=True,
            size_hint_y=None,
            height=dp(34),
        ))
        greeting_card.add_widget(MDLabel(
            text=f"Exam Goal: {goal}  |  {profile.get('daily_study_time', '1 hour')} daily",
            font_style="Body2",
            theme_text_color="Secondary",
            size_hint_y=None,
            height=dp(20),
        ))
        home_box.add_widget(greeting_card)

        daily_ch = get_daily_recommendation(self.chapters, profile)
        if daily_ch:
            ch, rec_time = daily_ch
            rec_card = MDCard(
                orientation="vertical",
                size_hint_y=None,
                height=dp(170),
                padding=dp(18),
                spacing=dp(6),
                elevation=8,
                radius=dp(18),
                md_bg_color=BG_NORMAL,
                ripple_behavior=True,
                on_release=lambda x, c=ch: self.open_chapter_detail(c),
            )
            header = MDBoxLayout(
                orientation="horizontal",
                size_hint_y=None,
                height=dp(24),
                spacing=dp(8),
                adaptive_height=True,
            )
            header.add_widget(MDIcon(
                icon="star",
                icon_size=dp(20),
                theme_text_color="Custom",
                text_color=ACCENT,
                pos_hint={"center_y": 0.5},
            ))
            header.add_widget(MDLabel(
                text="Recommended for Today",
                font_style="Subtitle2",
                theme_text_color="Custom",
                text_color=ACCENT,
                bold=True,
                size_hint_y=None,
                height=dp(22),
            ))
            rec_card.add_widget(header)
            rec_card.add_widget(MDLabel(
                text=ch.get("chapter", ""),
                font_style="H6",
                theme_text_color="Primary",
                bold=True,
                size_hint_y=None,
                height=dp(30),
            ))
            rec_card.add_widget(MDLabel(
                text=f"{ch.get('subject', '')}  |  {ch.get('pages', 0)} pages  |  {ch.get('weightage', 0)}% weightage",
                font_style="Body2",
                theme_text_color="Secondary",
                size_hint_y=None,
                height=dp(20),
            ))
            rec_card.add_widget(MDBoxLayout(
                orientation="horizontal",
                size_hint_y=None,
                height=dp(28),
                spacing=dp(8),
                children=[
                    MDCard(
                        orientation="vertical",
                        size_hint_x=None,
                        width=dp(100),
                        size_hint_y=None,
                        height=dp(26),
                        radius=dp(13),
                        md_bg_color=ACCENT,
                        elevation=0,
                        children=[MDLabel(
                            text=f"~{rec_time} min",
                            font_style="Caption",
                            halign="center",
                            valign="middle",
                            theme_text_color="Custom",
                            text_color=WHITE,
                            size_hint_y=None,
                            height=dp(26),
                        )],
                    ),
                    MDLabel(
                        text="recovery time",
                        font_style="Caption",
                        theme_text_color="Secondary",
                        valign="middle",
                        size_hint_y=None,
                        height=dp(26),
                    ),
                ],
            ))
            home_box.add_widget(rec_card)

        priority_list = get_priority_topics(self.chapters, profile, count=3)
        if priority_list:
            pri_header = self._make_card(
                title="Priority Topics",
                subtitle="Based on your weak subjects and goals",
                accent=True,
            )
            home_box.add_widget(pri_header)
            for ch, _ in priority_list:
                topic_card = MDCard(
                    orientation="horizontal",
                    size_hint_y=None,
                    height=dp(68),
                    padding=[dp(14), dp(8)],
                    spacing=dp(12),
                    elevation=2,
                    radius=dp(14),
                    md_bg_color=BG_NORMAL,
                    ripple_behavior=True,
                    on_release=lambda x, c=ch: self.open_chapter_detail(c),
                )
                left_box = MDBoxLayout(
                    orientation="vertical",
                    size_hint_x=0.7,
                    spacing=dp(2),
                    adaptive_height=True,
                )
                left_box.add_widget(MDLabel(
                    text=ch.get("chapter", ""),
                    font_style="Subtitle2",
                    theme_text_color="Primary",
                    bold=True,
                    size_hint_y=None,
                    height=dp(22),
                ))
                left_box.add_widget(MDLabel(
                    text=ch.get("subject", ""),
                    font_style="Caption",
                    theme_text_color="Secondary",
                    size_hint_y=None,
                    height=dp(18),
                ))
                topic_card.add_widget(left_box)
                right_box = MDBoxLayout(
                    orientation="vertical",
                    size_hint_x=0.3,
                    spacing=dp(2),
                    adaptive_height=True,
                )
                right_box.add_widget(MDLabel(
                    text=f"{ch.get('weightage', 0)}%",
                    font_style="Subtitle2",
                    theme_text_color="Custom",
                    text_color=ACCENT,
                    bold=True,
                    halign="right",
                    size_hint_y=None,
                    height=dp(22),
                ))
                right_box.add_widget(MDLabel(
                    text=f"{ch.get('pages', 0)}p",
                    font_style="Caption",
                    theme_text_color="Secondary",
                    halign="right",
                    size_hint_y=None,
                    height=dp(18),
                ))
                topic_card.add_widget(right_box)
                home_box.add_widget(topic_card)

        total_pages = sum(ch.get("pages", 0) for ch in self.chapters)
        avg_weight = round(sum(ch.get("weightage", 0) for ch in self.chapters) / max(len(self.chapters), 1), 1)
        stats_card = MDCard(
            orientation="vertical",
            size_hint_y=None,
            height=dp(110),
            padding=dp(16),
            spacing=dp(8),
            elevation=3,
            radius=dp(16),
            md_bg_color=BG_NORMAL,
        )
        stats_card.add_widget(MDLabel(
            text="Study Summary",
            font_style="Subtitle1",
            theme_text_color="Primary",
            bold=True,
            size_hint_y=None,
            height=dp(22),
        ))
        grid = MDBoxLayout(
            orientation="horizontal",
            size_hint_y=None,
            height=dp(56),
            spacing=dp(8),
        )
        for label, value in [
            ("Chapters", str(len(self.chapters))),
            ("Total Pages", str(total_pages)),
            ("Avg Weightage", f"{avg_weight}%"),
        ]:
            cell = MDBoxLayout(
                orientation="vertical",
                size_hint_x=0.33,
                spacing=dp(2),
            )
            cell.add_widget(MDLabel(
                text=value,
                font_style="H5",
                halign="center",
                theme_text_color="Custom",
                text_color=ACCENT,
                bold=True,
                size_hint_y=None,
                height=dp(30),
            ))
            cell.add_widget(MDLabel(
                text=label,
                font_style="Caption",
                halign="center",
                theme_text_color="Secondary",
                size_hint_y=None,
                height=dp(16),
            ))
            grid.add_widget(cell)
        stats_card.add_widget(grid)
        home_box.add_widget(stats_card)

        explore_card = MDCard(
            orientation="horizontal",
            size_hint_y=None,
            height=dp(60),
            padding=[dp(18), dp(10)],
            spacing=dp(12),
            elevation=3,
            radius=dp(16),
            md_bg_color=BG_LIGHT,
            ripple_behavior=True,
            on_release=lambda x: self._switch_to_search(),
        )
        explore_card.add_widget(MDIcon(
            icon="magnify",
            icon_size=dp(24),
            theme_text_color="Custom",
            text_color=ACCENT,
            pos_hint={"center_y": 0.5},
        ))
        explore_card.add_widget(MDLabel(
            text="Explore All Chapters",
            font_style="Subtitle1",
            theme_text_color="Primary",
            bold=True,
            size_hint_y=None,
            height=dp(24),
        ))
        explore_card.add_widget(MDIcon(
            icon="chevron-right",
            icon_size=dp(24),
            theme_text_color="Secondary",
            pos_hint={"center_y": 0.5},
        ))
        home_box.add_widget(explore_card)

    def _switch_to_search(self):
        main_screen = self.root.get_screen("main")
        main_screen.ids.bottom_nav.switch_tab("search_tab")

    def build_chapter_detail(self, chapter):
        detail_screen = self.root.get_screen("chapter_detail")
        detail_box = detail_screen.ids.detail_box
        detail_screen.ids.detail_toolbar.title = chapter.get("chapter", "Chapter Details")
        detail_box.clear_widgets()

        profile = self.profile or DEFAULT_PROFILE
        note_pref = profile.get("note_length_preference", "medium")
        pages = chapter.get("pages", 0)

        overview_card = MDCard(
            orientation="vertical",
            size_hint_y=None,
            height=dp(190),
            padding=dp(20),
            spacing=dp(8),
            elevation=6,
            radius=dp(16),
            md_bg_color=BG_LIGHT,
        )
        overview_card.add_widget(MDLabel(
            text=chapter.get("chapter", ""),
            font_style="H5",
            theme_text_color="Primary",
            bold=True,
            size_hint_y=None,
            height=dp(36),
        ))
        overview_card.add_widget(MDBoxLayout(size_hint_y=None, height=dp(1), md_bg_color=[0.3, 0.3, 0.3, 1]))
        overview_card.add_widget(MDLabel(
            text=f"Subject: {chapter.get('subject', 'General')}",
            font_style="Subtitle1",
            theme_text_color="Secondary",
            size_hint_y=None,
            height=dp(24),
        ))
        overview_card.add_widget(MDLabel(
            text=f"Pages: {pages}  |  Weightage: {chapter.get('weightage', 0)}%",
            font_style="Subtitle1",
            theme_text_color="Secondary",
            size_hint_y=None,
            height=dp(24),
        ))
        detail_box.add_widget(overview_card)

        recovery = calculate_recovery_time(pages)
        recovery_card = MDCard(
            orientation="vertical",
            size_hint_y=None,
            height=dp(90),
            padding=dp(16),
            spacing=dp(6),
            elevation=3,
            radius=dp(14),
            md_bg_color=BG_NORMAL,
        )
        rec_header = MDBoxLayout(
            orientation="horizontal",
            size_hint_y=None,
            height=dp(24),
            spacing=dp(8),
            adaptive_height=True,
        )
        rec_header.add_widget(MDIcon(
            icon="clock-outline",
            icon_size=dp(20),
            theme_text_color="Custom",
            text_color=ACCENT,
        ))
        rec_header.add_widget(MDLabel(
            text="Estimated Recovery Time",
            font_style="Subtitle2",
            theme_text_color="Primary",
            bold=True,
            size_hint_y=None,
            height=dp(22),
        ))
        recovery_card.add_widget(rec_header)
        recovery_card.add_widget(MDLabel(
            text=f"~{recovery} minutes  ({pages} pages x 0.12 x 8)",
            font_style="Body2",
            theme_text_color="Secondary",
            size_hint_y=None,
            height=dp(20),
        ))
        detail_box.add_widget(recovery_card)

        formulas = chapter.get("key_formulas", "")
        if formulas:
            formulas_card = self._make_detail_card(
                title="Key Formulas",
                icon="sigma",
                content=self._split_bullets(formulas),
            )
            detail_box.add_widget(formulas_card)

        notes_text = chapter.get("detailed_notes", "")
        if notes_text:
            display_notes = notes_text
            if note_pref == "short":
                display_notes = notes_text[:300] + ("..." if len(notes_text) > 300 else "")
            elif note_pref == "medium":
                display_notes = notes_text[:600] + ("..." if len(notes_text) > 600 else "")
            notes_card = self._make_detail_card(
                title="Detailed Notes",
                icon="text",
                content=[MDLabel(
                    text=display_notes,
                    font_style="Body2",
                    theme_text_color="Secondary",
                    size_hint_y=None,
                    height=self._calc_text_height(display_notes, 14, dp(280)),
                )],
            )
            detail_box.add_widget(notes_card)

        examples = chapter.get("examples", "")
        if examples:
            examples_card = self._make_detail_card(
                title="Examples",
                icon="lightbulb-on-outline",
                content=self._split_numbered(examples, "Example"),
            )
            detail_box.add_widget(examples_card)

        practice = chapter.get("practice_problems", "")
        if practice:
            practice_card = self._make_detail_card(
                title="Practice Problems",
                icon="pencil",
                content=self._split_numbered(practice, "Problem"),
            )
            detail_box.add_widget(practice_card)

    def _make_detail_card(self, title, icon="information", content=None):
        if content is None:
            content = []
        content_height = sum(w.height + dp(8) for w in content)
        total_height = max(dp(90), dp(50) + content_height)

        card = MDCard(
            orientation="vertical",
            size_hint_y=None,
            height=total_height,
            padding=dp(16),
            spacing=dp(8),
            elevation=3,
            radius=dp(14),
            md_bg_color=BG_NORMAL,
        )
        header = MDBoxLayout(
            orientation="horizontal",
            size_hint_y=None,
            height=dp(26),
            spacing=dp(8),
            adaptive_height=True,
        )
        header.add_widget(MDIcon(
            icon=icon,
            icon_size=dp(22),
            theme_text_color="Custom",
            text_color=ACCENT,
        ))
        header.add_widget(MDLabel(
            text=title,
            font_style="Subtitle2",
            theme_text_color="Primary",
            bold=True,
            size_hint_y=None,
            height=dp(24),
        ))
        card.add_widget(header)
        for w in content:
            card.add_widget(w)
        return card

    def _make_card(self, title="", subtitle="", content=None, accent=False):
        if content is None:
            content = []
        h = dp(50)
        if title:
            h += dp(28)
        if subtitle:
            h += dp(20)
        for w in content:
            h += w.height + dp(6)

        card = MDCard(
            orientation="vertical",
            size_hint_y=None,
            height=h,
            padding=dp(16),
            spacing=dp(6),
            elevation=3,
            radius=dp(14),
            md_bg_color=BG_LIGHT if accent else BG_NORMAL,
        )
        if title:
            card.add_widget(MDLabel(
                text=title,
                font_style="Subtitle1",
                theme_text_color="Primary",
                bold=True,
                size_hint_y=None,
                height=dp(26),
            ))
        if subtitle:
            card.add_widget(MDLabel(
                text=subtitle,
                font_style="Body2",
                theme_text_color="Secondary",
                size_hint_y=None,
                height=dp(18),
            ))
        for w in content:
            card.add_widget(w)
        return card

    def _split_bullets(self, text, max_items=8):
        parts = [p.strip() for p in text.split(";") if p.strip()]
        widgets = []
        for i, part in enumerate(parts[:max_items]):
            th = max(dp(22), self._calc_text_height(part, 14, dp(260)))
            row = MDBoxLayout(
                orientation="horizontal",
                size_hint_y=None,
                height=th,
                spacing=dp(6),
                padding=[dp(4), dp(1)],
                adaptive_height=False,
            )
            row.add_widget(MDLabel(
                text="\u2022",
                font_style="Body2",
                theme_text_color="Custom",
                text_color=ACCENT,
                size_hint_x=0.05,
                size_hint_y=None,
                height=dp(22),
            ))
            row.add_widget(MDLabel(
                text=part,
                font_style="Body2",
                theme_text_color="Secondary",
                size_hint_x=0.95,
                size_hint_y=None,
                height=th,
            ))
            widgets.append(row)
        if len(parts) > max_items:
            widgets.append(MDLabel(
                text=f"... and {len(parts) - max_items} more",
                font_style="Caption",
                theme_text_color="Secondary",
                size_hint_y=None,
                height=dp(16),
            ))
        return widgets

    def _split_numbered(self, text, prefix="Item"):
        parts = [p.strip() for p in text.split(";") if p.strip()]
        widgets = []
        for i, part in enumerate(parts):
            th = max(dp(26), self._calc_text_height(part, 14, dp(260)))
            row = MDBoxLayout(
                orientation="horizontal",
                size_hint_y=None,
                height=th + dp(4),
                spacing=dp(8),
                padding=[dp(4), dp(2)],
                adaptive_height=False,
            )
            num_card = MDCard(
                orientation="vertical",
                size_hint_x=None,
                width=dp(28),
                size_hint_y=None,
                height=dp(28),
                radius=[dp(14), dp(14), dp(14), dp(14)],
                md_bg_color=ACCENT,
                elevation=0,
                pos_hint={"center_y": 0.5},
            )
            num_card.add_widget(MDLabel(
                text=str(i + 1),
                font_style="Caption",
                halign="center",
                valign="middle",
                theme_text_color="Custom",
                text_color=WHITE,
                size_hint_y=None,
                height=dp(28),
            ))
            row.add_widget(num_card)
            row.add_widget(MDLabel(
                text=part,
                font_style="Body2",
                theme_text_color="Secondary",
                size_hint_x=0.85,
                size_hint_y=None,
                height=th,
            ))
            widgets.append(row)
        return widgets

    def _calc_text_height(self, text, font_size_sp, max_width_dp):
        if not text:
            return dp(20)
        chars_per_line = max(1, int(max_width_dp / dp(font_size_sp * 0.6)))
        lines = max(1, len(text) // chars_per_line + (1 if len(text) % chars_per_line else 0))
        return dp(lines * (font_size_sp * 1.5) + 6)

    def perform_search(self):
        main_screen = self.root.get_screen("main")
        query = main_screen.ids.search_input.text.strip()
        results_box = main_screen.ids.search_results
        results_box.clear_widgets()

        if not query:
            msg = MDCard(
                orientation="vertical",
                size_hint_y=None,
                height=dp(100),
                padding=dp(20),
                spacing=dp(8),
                elevation=2,
                radius=dp(16),
                md_bg_color=BG_NORMAL,
            )
            msg.add_widget(MDIcon(
                icon="magnify",
                icon_size=dp(36),
                pos_hint={"center_x": 0.5},
                theme_text_color="Custom",
                text_color=TEXT_SECONDARY,
            ))
            msg.add_widget(MDLabel(
                text="Enter a search term above",
                font_style="Body1",
                halign="center",
                theme_text_color="Secondary",
                size_hint_y=None,
                height=dp(22),
            ))
            results_box.add_widget(msg)
            return

        results = search_chapters(self.chapters, query)

        if not results:
            no_results = MDCard(
                orientation="vertical",
                size_hint_y=None,
                height=dp(160),
                padding=dp(24),
                spacing=dp(10),
                elevation=2,
                radius=dp(16),
                md_bg_color=BG_NORMAL,
            )
            no_results.add_widget(MDIcon(
                icon="file-search-outline",
                icon_size=dp(44),
                pos_hint={"center_x": 0.5},
                theme_text_color="Custom",
                text_color=ACCENT,
            ))
            no_results.add_widget(MDLabel(
                text="No chapters found",
                font_style="H6",
                halign="center",
                theme_text_color="Primary",
                size_hint_y=None,
                height=dp(26),
            ))
            no_results.add_widget(MDLabel(
                text=f'No results for "{query}". Try a different search term.',
                font_style="Body2",
                halign="center",
                theme_text_color="Secondary",
                size_hint_y=None,
                height=dp(20),
            ))
            results_box.add_widget(no_results)
            return

        results_box.add_widget(MDLabel(
            text=f"Found {len(results)} result{'s' if len(results) != 1 else ''}",
            font_style="Caption",
            theme_text_color="Secondary",
            size_hint_y=None,
            height=dp(18),
        ))

        for ch in results:
            ch_name = ch.get("chapter", "Unknown")
            subj = ch.get("subject", "")
            weight = ch.get("weightage", 0)
            pages = ch.get("pages", 0)
            rec = calculate_recovery_time(pages)
            card = MDCard(
                orientation="vertical",
                size_hint_y=None,
                height=dp(130),
                padding=dp(16),
                spacing=dp(6),
                elevation=3,
                radius=dp(16),
                md_bg_color=BG_NORMAL,
                ripple_behavior=True,
                on_release=lambda x, c=ch: self.open_chapter_detail(c),
            )
            card.add_widget(MDLabel(
                text=ch_name,
                font_style="Subtitle1",
                theme_text_color="Primary",
                bold=True,
                size_hint_y=None,
                height=dp(24),
            ))
            card.add_widget(MDLabel(
                text=f"{subj}  |  {pages} pages  |  Recovery: ~{rec} min",
                font_style="Body2",
                theme_text_color="Secondary",
                size_hint_y=None,
                height=dp(20),
            ))
            badge_row = MDBoxLayout(
                orientation="horizontal",
                size_hint_y=None,
                height=dp(28),
                spacing=dp(8),
                adaptive_height=False,
            )
            badge = MDCard(
                orientation="vertical",
                size_hint_x=None,
                width=dp(90),
                size_hint_y=None,
                height=dp(26),
                radius=[dp(13), dp(13), dp(13), dp(13)],
                md_bg_color=ACCENT,
                elevation=0,
            )
            badge.add_widget(MDLabel(
                text=f"{weight}% weightage",
                font_style="Caption",
                halign="center",
                valign="middle",
                theme_text_color="Custom",
                text_color=WHITE,
                size_hint_y=None,
                height=dp(26),
            ))
            badge_row.add_widget(badge)
            badge_row.add_widget(MDLabel(
                text=f"{pages} pages to study",
                font_style="Caption",
                theme_text_color="Secondary",
                valign="middle",
                size_hint_y=None,
                height=dp(26),
            ))
            card.add_widget(badge_row)
            results_box.add_widget(card)

    def clear_search(self):
        main_screen = self.root.get_screen("main")
        main_screen.ids.search_input.text = ""
        results_box = main_screen.ids.search_results
        results_box.clear_widgets()
        msg = MDCard(
            orientation="vertical",
            size_hint_y=None,
            height=dp(100),
            padding=dp(20),
            spacing=dp(8),
            elevation=2,
            radius=dp(16),
            md_bg_color=BG_NORMAL,
        )
        msg.add_widget(MDIcon(
            icon="magnify",
            icon_size=dp(36),
            pos_hint={"center_x": 0.5},
            theme_text_color="Custom",
            text_color=TEXT_SECONDARY,
        ))
        msg.add_widget(MDLabel(
            text="Enter a search term above",
            font_style="Body1",
            halign="center",
            theme_text_color="Secondary",
            size_hint_y=None,
            height=dp(22),
        ))
        results_box.add_widget(msg)

    def open_chapter_detail(self, chapter):
        detail_screen = self.root.get_screen("chapter_detail")
        detail_screen.show_chapter(chapter)
        self.root.current = "chapter_detail"

    def build_settings(self):
        main_screen = self.root.get_screen("main")
        profile_box = main_screen.ids.profile_box
        profile_box.clear_widgets()

        profile = self.profile or DEFAULT_PROFILE

        profile_card = MDCard(
            orientation="vertical",
            size_hint_y=None,
            height=dp(220),
            padding=dp(24),
            spacing=dp(8),
            elevation=4,
            radius=dp(16),
            md_bg_color=BG_LIGHT,
        )
        profile_card.add_widget(MDIcon(
            icon="account-circle",
            icon_size=dp(60),
            pos_hint={"center_x": 0.5},
            theme_text_color="Custom",
            text_color=ACCENT,
        ))
        profile_card.add_widget(MDLabel(
            text=profile.get("name", "Student"),
            font_style="H4",
            halign="center",
            theme_text_color="Primary",
            bold=True,
            size_hint_y=None,
            height=dp(36),
        ))
        profile_card.add_widget(MDLabel(
            text=f"Exam Goal: {profile.get('exam_goal', 'boards').title()}",
            font_style="Body1",
            halign="center",
            theme_text_color="Secondary",
            size_hint_y=None,
            height=dp(22),
        ))
        profile_card.add_widget(MDLabel(
            text=f"Daily Study: {profile.get('daily_study_time', '1 hour')}  |  Style: {profile.get('difficulty_preference', 'medium').title()}",
            font_style="Body1",
            halign="center",
            theme_text_color="Secondary",
            size_hint_y=None,
            height=dp(22),
        ))
        profile_box.add_widget(profile_card)

        edit_card = MDCard(
            orientation="vertical",
            size_hint_y=None,
            height=dp(440),
            padding=dp(20),
            spacing=dp(10),
            elevation=3,
            radius=dp(16),
            md_bg_color=BG_NORMAL,
        )
        edit_card.add_widget(MDLabel(
            text="Edit Preferences",
            font_style="H6",
            theme_text_color="Primary",
            bold=True,
            size_hint_y=None,
            height=dp(28),
        ))

        name_field = MDTextField(
            text=profile.get("name", ""),
            hint_text="Name",
            mode="fill",
            size_hint_x=1,
        )
        self._settings_save_name = name_field
        edit_card.add_widget(name_field)

        weak_field = MDTextField(
            text=", ".join(profile.get("weak_subjects", [])),
            hint_text="Weak subjects (comma separated)",
            mode="fill",
            size_hint_x=1,
        )
        self._settings_save_weak = weak_field
        edit_card.add_widget(weak_field)

        fav_field = MDTextField(
            text=", ".join(profile.get("favorite_subjects", [])),
            hint_text="Favorite subjects (comma separated)",
            mode="fill",
            size_hint_x=1,
        )
        self._settings_save_fav = fav_field
        edit_card.add_widget(fav_field)

        edit_card.add_widget(MDLabel(
            text="Exam Goal:",
            font_style="Caption",
            theme_text_color="Secondary",
            size_hint_y=None,
            height=dp(16),
        ))

        goal_box = MDBoxLayout(
            orientation="horizontal",
            size_hint_y=None,
            height=dp(40),
            spacing=dp(8),
        )
        edit_card.add_widget(goal_box)

        goals = ["boards", "competitive", "jee", "neet"]
        goal_labels = ["Boards", "Competitive", "JEE", "NEET"]
        current_goal = profile.get("exam_goal", "boards")
        self._settings_goal_btns = []

        for val, label in zip(goals, goal_labels):
            is_sel = val == current_goal
            btn = MDFlatButton(
                text=label,
                size_hint_x=1,
                md_bg_color=ACCENT if is_sel else [0, 0, 0, 0],
                theme_text_color="Custom" if is_sel else "Primary",
                text_color=WHITE if is_sel else None,
                on_release=lambda x, v=val: self._settings_select_goal(v),
            )
            goal_box.add_widget(btn)
            self._settings_goal_btns.append(btn)

        save_btn = MDRaisedButton(
            text="Save Changes",
            size_hint_x=1,
            size_hint_y=None,
            height=dp(48),
            on_release=lambda x: self._save_settings(),
            md_bg_color=ACCENT,
        )
        edit_card.add_widget(save_btn)
        profile_box.add_widget(edit_card)

        refresh_btn = MDRaisedButton(
            text="Refresh Recommendations",
            size_hint_x=1,
            size_hint_y=None,
            height=dp(48),
            on_release=lambda x: self._refresh_and_notify(),
            md_bg_color=ACCENT,
        )
        profile_box.add_widget(refresh_btn)

    def _settings_select_goal(self, val):
        for btn, gval in zip(self._settings_goal_btns, ["boards", "competitive", "jee", "neet"]):
            if gval == val:
                btn.md_bg_color = ACCENT
                btn.theme_text_color = "Custom"
                btn.text_color = WHITE
            else:
                btn.md_bg_color = [0, 0, 0, 0]
                btn.theme_text_color = "Primary"
        if self.profile:
            self.profile["exam_goal"] = val

    def _save_settings(self):
        if not self.profile:
            return
        if self._settings_save_name:
            self.profile["name"] = self._settings_save_name.text.strip() or "Student"
        if self._settings_save_weak:
            wt = self._settings_save_weak.text.strip()
            self.profile["weak_subjects"] = [s.strip() for s in wt.split(",") if s.strip()]
        else:
            self.profile["weak_subjects"] = []
        if self._settings_save_fav:
            ft = self._settings_save_fav.text.strip()
            self.profile["favorite_subjects"] = [s.strip() for s in ft.split(",") if s.strip()]
        else:
            self.profile["favorite_subjects"] = []
        save_profile(self.profile)
        self._show_snackbar("Profile saved!")

    def _refresh_and_notify(self):
        self.build_home_dashboard()
        self._show_snackbar("Recommendations refreshed!")

    def _show_snackbar(self, text):
        try:
            from kivymd.uix.snackbar import Snackbar
            Snackbar(text=text, duration=2).open()
        except Exception:
            pass

    def on_start(self):
        if self.profile and self.profile.get("name"):
            Clock.schedule_once(lambda dt: self.build_home_dashboard(), 0.1)
        self._setup_profile_tab()

    def _setup_profile_tab(self):
        main_screen = self.root.get_screen("main") if "main" in [s.name for s in self.root.screens] else None
        if main_screen:
            main_screen.ids.bottom_nav.bind(on_tab_switch=self._on_tab_switch)

    def _on_tab_switch(self, nav, tab, prev_tab, *args):
        if tab.name == "profile_tab":
            self.build_settings()
        elif tab.name == "home_tab":
            self.build_home_dashboard()


if __name__ == "__main__":
    Window.size = (400, 750)
    CBSEApp().run()
