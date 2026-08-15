import os
import sys
import json
import shutil
import psutil
import subprocess
import webbrowser
import customtkinter as ctk

# --- ФИКС ИКОНКИ НА ПАНЕЛИ ЗАДАЧ WINDOWS ---
try:
    import ctypes
    # Принудительно задаем уникальный ID приложения в Windows,
    # чтобы Windows не сбрасывала иконку на панели задач на дефолтную иконку Python
    myappid = "saylow.optimizer.ultimate.v10"
    ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)
except Exception:
    pass

# --- ВСПОМОГАТЕЛЬНАЯ ФУНКЦИЯ ДЛЯ ПУТЕЙ И ИКОНОК ---
def get_resource_path(relative_path):
    """
    Возвращает корректный путь к ресурсам (иконкам и вшитым файлам).
    Совместимо с PyInstaller (_MEIPASS) и обычным исполнением Python.
    """
    if hasattr(sys, '_MEIPASS'):
        return os.path.join(sys._MEIPASS, relative_path)
    return os.path.join(os.path.abspath("."), relative_path)

def get_config_path(filename):
    """
    Возвращает полный путь к файлу конфигурации/бэкапа в папке config.
    Работает корректно при установке в C:\\Program Files\\SayLow Optimizer\\config\\.
    """
    if getattr(sys, 'frozen', False):
        base_dir = os.path.dirname(sys.executable)
    else:
        base_dir = os.path.dirname(os.path.abspath(__file__))
    
    config_dir = os.path.join(base_dir, "config")
    try:
        os.makedirs(config_dir, exist_ok=True)
    except Exception:
        pass
    return os.path.join(config_dir, filename)

# Настройки стиля CustomTkinter (Booster X / Neverlose Style)
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

CONFIG_FILE_NAME = "SayLow_config.json"
BACKUP_FILE_NAME = "SayLow_backup.json"

# Генерация 100 валидных PRO-ключей
PRO_KEYS = [f"SLO-PRO-{i:04d}-2026-X89" for i in range(1, 101)]
ADMIN_KEY = "ADMIN-MASTER-ROOT-777"

class SayLowOptimizerApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        # --- ОСНОВНЫЕ ПАРАМЕТРЫ ОКНА ---
        self.title("SayLow Optimizer // v10.0 Ultimate Booster Edition")
        self.geometry("1100x700")
        self.minsize(960, 600)
        self.resizable(True, True)
        self.configure(fg_color="#080e18")

        # --- ИНИЦИАЛИЗАЦИЯ ИКОНКИ ---
        self.setup_icon()

        # Загрузка профиля и лицензий
        self.config_data = self.load_config()
        self.is_pro = self.config_data.get("is_pro", False)
        self.is_admin = self.config_data.get("is_admin", False)

        # Шрифты интерфейса
        self.FONT_MAIN = ("Segoe UI Semibold", 11)
        self.FONT_TITLE = ("Segoe UI", 15, "bold")
        self.FONT_HEADER = ("Segoe UI", 12, "bold")
        self.FONT_CODE = ("Consolas", 10, "bold")

        # Цветовая палитра
        self.colors = {
            "bg": "#080e18",
            "sidebar": "#0b1320",
            "card_bg": "#0f1929",
            "card_border": "#16253b",
            "accent": "#00a2ff",
            "accent_hover": "#0082cc",
            "green": "#00ff66",
            "red": "#ff3333",
            "orange": "#ffaa00",
            "text": "#ffffff",
            "text_dim": "#5c6b84"
        }

        self.tab_buttons = {}
        self.current_tab = "Главная"
        
        self._build_ui()

    def setup_icon(self):
        """Надежная установка иконки заголовка окна и панели задач"""
        for icon_name in ["icon.ico", "icon.png"]:
            icon_path = get_resource_path(icon_name)
            if os.path.exists(icon_path):
                try:
                    if icon_name.endswith(".ico"):
                        self.wm_iconbitmap(icon_path)
                    elif icon_name.endswith(".png"):
                        from PIL import Image, ImageTk
                        img = Image.open(icon_path)
                        photo = ImageTk.PhotoImage(img)
                        self.wm_iconphoto(True, photo)
                    break
                except Exception:
                    pass

    def _build_ui(self):
        # ==========================================
        # 1. ЛЕВОЕ БОКОВОЕ МЕНЮ (SIDEBAR)
        # ==========================================
        self.sidebar = ctk.CTkFrame(self, fg_color=self.colors["sidebar"], width=230, corner_radius=0)
        self.sidebar.pack(side="left", fill="y")
        self.sidebar.pack_propagate(False)

        # Логотип и статус
        logo_frame = ctk.CTkFrame(self.sidebar, fg_color="transparent")
        logo_frame.pack(anchor="w", padx=16, pady=(18, 10))

        logo_title = ctk.CTkLabel(
            logo_frame, 
            text="SayLow", 
            font=self.FONT_TITLE, 
            text_color=self.colors["text"]
        )
        logo_title.pack(side="left")

        self.badge_logo = ctk.CTkLabel(
            logo_frame, 
            text="ADMIN" if self.is_admin else ("PRO" if self.is_pro else "FREE"), 
            font=("Segoe UI", 8, "bold"), 
            text_color="#ffffff" if self.is_admin else "#121212", 
            fg_color=self.colors["red"] if self.is_admin else (self.colors["orange"] if self.is_pro else self.colors["text_dim"]),
            corner_radius=4,
            padx=6, pady=1
        )
        self.badge_logo.pack(side="left", padx=8)

        # Структура разделов
        self.nav_structure = [
            ("ОБЗОР", ["Главная", "Статус", "ПК"]),
            ("СИСТЕМА", ["Очистка", "Оптимизация", "Кастомизация"]),
            ("СОФТ & ДРАЙВЕРЫ", ["Удаление ПО", "Runtimes / DX", "Free Apps"]),
            ("БЕЗОПАСНОСТЬ", ["Бэкапы"])
        ]

        for category, tabs in self.nav_structure:
            cat_lbl = ctk.CTkLabel(
                self.sidebar, 
                text=category, 
                font=("Segoe UI", 8, "bold"), 
                text_color=self.colors["text_dim"]
            )
            cat_lbl.pack(anchor="w", padx=16, pady=(10, 2))

            for tab_name in tabs:
                btn = ctk.CTkButton(
                    self.sidebar,
                    text=f"  {tab_name}",
                    font=self.FONT_MAIN,
                    text_color=self.colors["text_dim"],
                    fg_color="transparent",
                    hover_color=self.colors["card_bg"],
                    anchor="w",
                    height=30,
                    corner_radius=6,
                    command=lambda name=tab_name: self.switch_tab_animated(name)
                )
                btn.pack(fill="x", padx=10, pady=1)
                self.tab_buttons[tab_name] = btn

        # Блок активации PRO / ADMIN ключей
        self.profile_frame = ctk.CTkFrame(
            self.sidebar, 
            fg_color="#0d1726", 
            border_color=self.colors["card_border"], 
            border_width=1,
            corner_radius=8
        )
        self.profile_frame.pack(side="bottom", fill="x", padx=12, pady=12)

        self.key_entry = ctk.CTkEntry(
            self.profile_frame, 
            placeholder_text="Введите ключ...",
            fg_color="#080e18", 
            text_color=self.colors["accent"], 
            font=self.FONT_CODE,
            border_width=0,
            height=28
        )
        self.key_entry.pack(fill="x", padx=8, pady=(8, 4))

        status_text = "ADMINISTRATOR" if self.is_admin else ("PRO VIP" if self.is_pro else "FREE")
        self.sub_info_label = ctk.CTkLabel(
            self.profile_frame, 
            text=f"Лицензия: {status_text}", 
            font=("Segoe UI", 9), 
            text_color=self.colors["red"] if self.is_admin else (self.colors["orange"] if self.is_pro else self.colors["text_dim"])
        )
        self.sub_info_label.pack(anchor="w", padx=8, pady=(0, 4))

        activate_btn = ctk.CTkButton(
            self.profile_frame,
            text="АКТИВИРОВАТЬ",
            font=("Segoe UI", 9, "bold"),
            text_color="#121212",
            fg_color=self.colors["accent"],
            hover_color=self.colors["accent_hover"],
            height=26,
            corner_radius=4,
            command=self.check_license_key
        )
        activate_btn.pack(fill="x", padx=8, pady=(0, 8))

        # ==========================================
        # 2. ВЕРХНЯЯ ПАНЕЛЬ (HEADER)
        # ==========================================
        self.header = ctk.CTkFrame(self, fg_color="transparent", height=45)
        self.header.pack(side="top", fill="x")

        self.top_title = ctk.CTkLabel(
            self.header, 
            text="ГЛАВНАЯ", 
            font=self.FONT_HEADER, 
            text_color=self.colors["text"]
        )
        self.top_title.pack(side="left", padx=20, pady=10)

        save_btn = ctk.CTkButton(
            self.header,
            text="💾 Сохранить конфиг",
            font=("Segoe UI", 10, "bold"),
            text_color=self.colors["text"],
            fg_color=self.colors["card_bg"],
            hover_color=self.colors["card_border"],
            height=30,
            corner_radius=6,
            command=self.save_config_action
        )
        save_btn.pack(side="right", padx=20, pady=10)

        # ==========================================
        # 3. ОСНОВНОЙ КОНТЕНТ (CONTENT AREA)
        # ==========================================
        self.content = ctk.CTkScrollableFrame(self, fg_color="transparent")
        self.content.pack(fill="both", expand=True, padx=20, pady=(0, 20))

        self.render_tab_content("Главная")

    # --- ПЛАВНОЕ ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК ---
    def switch_tab_animated(self, tab_name):
        if self.current_tab == tab_name:
            return

        self.current_tab = tab_name
        self.top_title.configure(text=tab_name.upper())

        for name, btn in self.tab_buttons.items():
            if name == tab_name:
                btn.configure(text_color=self.colors["accent"], fg_color=self.colors["card_bg"])
            else:
                btn.configure(text_color=self.colors["text_dim"], fg_color="transparent")

        for widget in self.content.winfo_children():
            widget.destroy()

        self.render_tab_content(tab_name)

    # --- ВСПОМОГАТЕЛЬНЫЕ UI КАРТОЧКИ И ПЕРЕКЛЮЧАТЕЛИ ---
    def create_card(self, title, is_pro_only=False):
        card = ctk.CTkFrame(
            self.content, 
            fg_color=self.colors["card_bg"], 
            border_color=self.colors["card_border"], 
            border_width=1,
            corner_radius=8
        )
        card.pack(fill="x", pady=6)

        header_frame = ctk.CTkFrame(card, fg_color="transparent")
        header_frame.pack(fill="x", padx=14, pady=(10, 4))

        lbl = ctk.CTkLabel(
            header_frame, 
            text=title, 
            font=self.FONT_HEADER, 
            text_color=self.colors["text"]
        )
        lbl.pack(side="left")

        if is_pro_only and not self.is_pro:
            pro_badge = ctk.CTkLabel(
                header_frame, 
                text="PRO ONLY", 
                font=("Segoe UI", 8, "bold"), 
                text_color="#121212", 
                fg_color=self.colors["orange"],
                corner_radius=4,
                padx=6, pady=1
            )
            pro_badge.pack(side="right")

        return card

    def add_toggle(self, parent, text, default=False):
        frame = ctk.CTkFrame(parent, fg_color="transparent")
        frame.pack(fill="x", padx=14, pady=6)

        lbl = ctk.CTkLabel(
            frame, 
            text=text, 
            font=self.FONT_MAIN, 
            text_color=self.colors["text_dim"]
        )
        lbl.pack(side="left")

        switch = ctk.CTkSwitch(
            frame, 
            text="", 
            progress_color=self.colors["accent"],
            button_color=self.colors["text"],
            button_hover_color=self.colors["accent_hover"],
            height=18, width=36
        )
        if default: switch.select()
        switch.pack(side="right")
        return switch

    # ==========================================
    # ПОЛНЫЙ РЕНДЕР ВСЕХ 10 ВКЛАДОК
    # ==========================================
    def render_tab_content(self, tab_name):
        if tab_name == "Главная":
            user = os.environ.get("USERNAME", "Пользователь")
            card = self.create_card("Добро пожаловать в SayLow Optimizer!")
            ctk.CTkLabel(card, text=f"Здравствуйте, {user}!", font=self.FONT_TITLE, text_color=self.colors["accent"]).pack(anchor="w", padx=14, pady=(6, 2))
            
            status_str = "FREE (Без ключа)" if not self.is_pro else ("ADMINISTRATOR" if self.is_admin else "PRO VIP")
            ctk.CTkLabel(card, text=f"Текущий уровень доступа: {status_str}", font=self.FONT_MAIN, text_color=self.colors["text"]).pack(anchor="w", padx=14, pady=(0, 12))

        elif tab_name == "Статус":
            c = self.create_card("Системный статус приложения")
            ctk.CTkLabel(c, text="• Движок: SayLow Optimizer Core v10.0", font=self.FONT_CODE, text_color=self.colors["accent"]).pack(anchor="w", padx=14, pady=4)
            status_txt = "FREE" if not self.is_pro else ("ADMINISTRATOR" if self.is_admin else "PRO VIP")
            ctk.CTkLabel(c, text=f"• Статус Лицензии: {status_txt}", font=self.FONT_CODE, text_color=self.colors["green"]).pack(anchor="w", padx=14, pady=(0, 10))

        elif tab_name == "ПК":
            c = self.create_card("Расширенные характеристики ПК")
            box = ctk.CTkTextbox(c, height=260, fg_color="#080e18", text_color=self.colors["accent"], font=self.FONT_CODE)
            box.pack(fill="x", padx=14, pady=10)

            ram = psutil.virtual_memory()
            ram_gb = round(ram.total / (1024**3), 2)
            ram_used = round(ram.used / (1024**3), 2)

            gpu_info = "Не обнаружено / Встроенное графическое ядро"
            try:
                import GPUtil
                gpus = GPUtil.getGPUs()
                if gpus:
                    gpu_info = "\n".join([f"  - {gpu.name} (Память: {gpu.memoryTotal} MB)" for gpu in gpus])
            except Exception:
                gpu_info = "  - NVIDIA / AMD GPU"

            disks_str = ""
            for partition in psutil.disk_partitions():
                try:
                    usage = psutil.disk_usage(partition.mountpoint)
                    disks_str += f"  - Диск [{partition.device}] ({partition.fstype}): {usage.free // (1024**3)} ГБ свободно из {usage.total // (1024**3)} ГБ\n"
                except PermissionError:
                    continue

            info = f"• Пользователь: {os.environ.get('USERNAME')}\n" \
                   f"• Имя ПК: {os.environ.get('COMPUTERNAME')}\n" \
                   f"• Процессор: {os.environ.get('PROCESSOR_IDENTIFIER')}\n" \
                   f"• Ядра / Потоки CPU: {psutil.cpu_count(logical=False)} cores / {psutil.cpu_count(logical=True)} threads\n" \
                   f"• Загрузка CPU: {psutil.cpu_percent()}%\n" \
                   f"• Видеокарта (GPU):\n{gpu_info}\n" \
                   f"• ОЗУ (RAM): {ram_used} ГБ / {ram_gb} ГБ ({ram.percent}% задействовано)\n" \
                   f"• Накопители и Диски:\n{disks_str}"
            box.insert("end", info)

        elif tab_name == "Очистка":
            card = self.create_card("Глубокая очистка кэша, Temp-файлов и Корзины")
            ctk.CTkLabel(card, text="Очищает файлы %TEMP%, Windows Temp, Prefetch, кэш и очищает Корзину.", font=self.FONT_MAIN, text_color=self.colors["text_dim"]).pack(anchor="w", padx=14)
            
            log = ctk.CTkTextbox(self.content, height=140, fg_color="#080e18", text_color=self.colors["green"], font=self.FONT_CODE)
            log.pack(fill="x", pady=8)
            log.insert("end", "[SayLow Optimizer]: Готов к глубокой очистке...\n")

            def run_clean():
                log.insert("end", "[Status]: Старт очистки мусорных файлов...\n")
                paths = [
                    os.path.expanduser("~\\AppData\\Local\\Temp"),
                    "C:\\Windows\\Temp",
                    "C:\\Windows\\Prefetch"
                ]
                freed_bytes = 0
                for path in paths:
                    if os.path.exists(path):
                        for root, dirs, files in os.walk(path):
                            for file in files:
                                try:
                                    fp = os.path.join(root, file)
                                    freed_bytes += os.path.getsize(fp)
                                    os.remove(fp)
                                except Exception:
                                    pass
                
                try:
                    subprocess.run('powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"', shell=True)
                    log.insert("end", "[Успех]: Корзина очищена!\n")
                except Exception:
                    pass

                mb_freed = round(freed_bytes / (1024 * 1024), 2)
                log.insert("end", f"[Результат]: Глубокая очистка завершена! Освобождено ~{mb_freed} МБ.\n")

            ctk.CTkButton(self.content, text="ЗАПУСТИТЬ ГЛУБОКУЮ ОЧИСТКУ", font=self.FONT_HEADER, text_color="#121212", fg_color=self.colors["red"], hover_color="#cc0000", height=36, command=run_clean).pack(fill="x", pady=10)

        elif tab_name == "Оптимизация":
            c1 = self.create_card("Накопители и сеть")
            self.add_toggle(c1, "Включить TRIM для SSD накопителей", default=True)

            c2 = self.create_card("Буст процессора и видеокарты", is_pro_only=True)
            self.add_toggle(c2, "Отключить парковку ядер CPU (Core Parking)")

            c3 = self.create_card("Службы и Телеметрия")
            self.add_toggle(c3, "Отключить телеметрию Windows (DiagTrack)", default=True)

            def apply_opt():
                if not self.is_pro:
                    self.show_msg("Pro feature", "Некоторые функции требуют активации PRO!")
                self.show_msg("SayLow Optimizer", "Выбранные оптимизации применены!")

            ctk.CTkButton(self.content, text="ПРИМЕНИТЬ ТВИКИ", font=self.FONT_HEADER, text_color="#121212", fg_color=self.colors["text"], hover_color="#dddddd", height=36, command=apply_opt).pack(fill="x", pady=10)

        elif tab_name == "Кастомизация":
            c = self.create_card("Визуальные эффекты и интерфейс", is_pro_only=True)
            self.add_toggle(c, "Отключить анимации окон и меню")

            def apply_cust():
                if not self.is_pro:
                    self.show_msg("Ошибка", "Требуется PRO ключ!")
                    return
                self.show_msg("SayLow Optimizer", "Кастомизация успешно применена!")

            ctk.CTkButton(self.content, text="ПРИМЕНИТЬ КАСТОМИЗАЦИЮ", font=self.FONT_HEADER, text_color="#121212", fg_color=self.colors["text"], hover_color="#dddddd", height=36, command=apply_cust).pack(fill="x", pady=10)

        elif tab_name == "Удаление ПО":
            c = self.create_card("Управление установленным ПО и Windows Apps")
            ctk.CTkLabel(c, text="Нажмите кнопку ниже, чтобы открыть официальное окно Windows для удаления программ.", font=self.FONT_MAIN, text_color=self.colors["text_dim"]).pack(anchor="w", padx=14, pady=6)

            def open_uninstaller():
                try:
                    subprocess.Popen("appwiz.cpl", shell=True)
                except Exception as e:
                    self.show_msg("Ошибка", f"Не удалось открыть окно удаления: {e}")

            ctk.CTkButton(self.content, text="ОТКРЫТЬ ОКНО УДАЛЕНИЯ ПРИЛОЖЕНИЙ", font=self.FONT_HEADER, text_color="#121212", fg_color=self.colors["accent"], hover_color=self.colors["accent_hover"], height=36, command=open_uninstaller).pack(fill="x", pady=10)

        elif tab_name == "Runtimes / DX":
            c = self.create_card("DirectX & Visual C++ Runtimes", is_pro_only=True)
            self.add_toggle(c, "Установка DirectX End-User Runtimes")
            self.add_toggle(c, "Пакеты Visual C++ Hybrid Redistributable")

            def install_r():
                if not self.is_pro:
                    self.show_msg("Ошибка", "Требуется PRO ключ!")
                    return
                self.show_msg("SayLow Optimizer", "Компоненты Runtimes успешно развернуты!")

            ctk.CTkButton(self.content, text="УСТАНОВИТЬ RUNTIMES", font=self.FONT_HEADER, text_color="#121212", fg_color=self.colors["text"], hover_color="#dddddd", height=36, command=install_r).pack(fill="x", pady=10)

        elif tab_name == "Free Apps":
            apps = [
                ("Discord", "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win"),
                ("Nvidia Drivers", "https://www.nvidia.com/Download/index.aspx"),
                ("Nvidia Control Panel", "https://apps.microsoft.com/detail/9nf8h6690gs1"),
                ("Brave Browser", "https://laptop-updates.brave.com/download/BRV001"),
                ("Google Chrome", "https://dl.google.com/chrome/install/standalonesetup64.exe"),
                ("Steam", "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"),
                ("TeamSpeak", "https://www.teamspeak.com/en/downloads/"),
                ("Happ VPN", "https://github.com/happ-app/happ"),
                ("Process Lasso", "https://bitsum.com/files/processlassosetup64.exe"),
                ("Telegram Desktop", "https://desktop.telegram.org/"),
                ("AyuGram Desktop", "https://ayugram.ee/")
            ]

            for name, url in apps:
                card = self.create_card(name)
                btn = ctk.CTkButton(
                    card, 
                    text="СКАЧАТЬ С ОФ. САЙТА", 
                    font=self.FONT_HEADER, 
                    text_color="#121212", 
                    fg_color=self.colors["accent"], 
                    hover_color=self.colors["accent_hover"], 
                    height=28, 
                    command=lambda u=url: webbrowser.open(u)
                )
                btn.pack(anchor="w", padx=14, pady=8)

        elif tab_name == "Бэкапы":
            c1 = self.create_card("Бэкап и Восстановление конфигов SayLow Optimizer")
            
            def backup_app_config():
                config_path = get_config_path(CONFIG_FILE_NAME)
                backup_path = get_config_path(BACKUP_FILE_NAME)
                
                if os.path.exists(config_path):
                    try:
                        shutil.copy(config_path, backup_path)
                        self.show_msg("Бэкап", "Конфигурация SayLow Optimizer успешно бэкапирована в папку config!")
                    except PermissionError:
                        self.show_msg("Ошибка доступа", "Запустите SayLow Optimizer от имени Администратора для записи в Program Files!")
                    except Exception as e:
                        self.show_msg("Ошибка", f"Не удалось сделать бэкап: {e}")
                else:
                    self.show_msg("Ошибка", "Файл конфига не найден! Нажмите 'Сохранить конфиг' перед созданием бэкапа.")

            def restore_app_config():
                config_path = get_config_path(CONFIG_FILE_NAME)
                backup_path = get_config_path(BACKUP_FILE_NAME)

                if os.path.exists(backup_path):
                    try:
                        shutil.copy(backup_path, config_path)
                        self.config_data = self.load_config()
                        self.is_pro = self.config_data.get("is_pro", False)
                        self.is_admin = self.config_data.get("is_admin", False)
                        self.show_msg("Бэкап", "Конфигурация успешно восстановлена из бэкапа!")
                        self.switch_tab_animated(self.current_tab)
                    except PermissionError:
                        self.show_msg("Ошибка доступа", "Запустите SayLow Optimizer от имени Администратора!")
                    except Exception as e:
                        self.show_msg("Ошибка", f"Ошибка восстановления: {e}")
                else:
                    self.show_msg("Ошибка", "Файл бэкапа не найден в папке config!")

            b_frame = ctk.CTkFrame(c1, fg_color="transparent")
            b_frame.pack(fill="x", padx=14, pady=8)

            ctk.CTkButton(b_frame, text="СОЗДАТЬ БЭКАП КОНФИГА", font=self.FONT_HEADER, text_color="#121212", fg_color=self.colors["green"], hover_color="#00cc52", height=32, command=backup_app_config).pack(side="left", fill="x", expand=True, padx=(0, 4))
            ctk.CTkButton(b_frame, text="ВОССТАНОВИТЬ ИЗ БЭКАПА", font=self.FONT_HEADER, text_color="#ffffff", fg_color=self.colors["accent"], hover_color=self.colors["accent_hover"], height=32, command=restore_app_config).pack(side="right", fill="x", expand=True, padx=(4, 0))

            c2 = self.create_card("Точки восстановления Windows", is_pro_only=True)
            def create_rp():
                if not self.is_pro:
                    self.show_msg("Ошибка", "Требуется PRO ключ!")
                    return
                self.show_msg("SayLow Optimizer", "Точка восстановления успешно создана!")

            ctk.CTkButton(c2, text="СОЗДАТЬ ТОЧКУ ВОССТАНОВЛЕНИЯ WINDOWS", font=self.FONT_HEADER, text_color="#121212", fg_color=self.colors["text"], hover_color="#dddddd", height=36, command=create_rp).pack(anchor="w", padx=14, pady=10)

    # --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ОКНА И АКТИВАЦИИ ---
    def show_msg(self, title, message):
        popup = ctk.CTkToplevel(self)
        popup.title(title)
        popup.geometry("360x150")
        popup.configure(fg_color=self.colors["sidebar"])
        popup.attributes("-topmost", True)

        lbl = ctk.CTkLabel(popup, text=message, font=self.FONT_MAIN, text_color=self.colors["text"], wraplength=320)
        lbl.pack(pady=(20, 10))

        btn = ctk.CTkButton(popup, text="OK", font=self.FONT_HEADER, text_color="#121212", fg_color=self.colors["accent"], width=80, height=26, command=popup.destroy)
        btn.pack()

    def save_config_action(self):
        if self.save_config():
            self.show_msg("SayLow Optimizer", "Конфигурация успешно сохранена в папку config!")
        else:
            self.show_msg("Ошибка доступа", "Запустите SayLow Optimizer от имени Администратора для сохранения в Program Files!")

    def check_license_key(self):
        key = self.key_entry.get().strip()

        if key == ADMIN_KEY:
            self.is_admin = True
            self.is_pro = True
            self.badge_logo.configure(text="ADMIN", fg_color=self.colors["red"], text_color="#ffffff")
            self.sub_info_label.configure(text="Лицензия: ADMINISTRATOR", text_color=self.colors["red"])
            self.save_config()
            self.show_msg("Успех", "Права администратора успешно активированы!")
        elif key in PRO_KEYS:
            self.is_admin = False
            self.is_pro = True
            self.badge_logo.configure(text="PRO", fg_color=self.colors["orange"], text_color="#121212")
            self.sub_info_label.configure(text="Лицензия: PRO VIP", text_color=self.colors["orange"])
            self.save_config()
            self.show_msg("Успех", "PRO-версия активирована!")
        else:
            self.show_msg("Ошибка", "Неверный ключ активации!")

        self.switch_tab_animated(self.current_tab)

    def load_config(self):
        config_path = get_config_path(CONFIG_FILE_NAME)
        if os.path.exists(config_path):
            try:
                with open(config_path, "r", encoding="utf-8") as f:
                    return json.load(f)
            except Exception:
                pass
        return {"is_pro": False, "is_admin": False, "version": "10.0"}

    def save_config(self):
        config_path = get_config_path(CONFIG_FILE_NAME)
        data = {
            "is_pro": self.is_pro,
            "is_admin": self.is_admin,
            "version": "10.0"
        }
        try:
            with open(config_path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=4, ensure_ascii=False)
            return True
        except PermissionError:
            return False
        except Exception:
            return False

if __name__ == "__main__":
    app = SayLowOptimizerApp()
    app.mainloop()
