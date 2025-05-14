module.exports = {
  types: [
    { value: "feat", name: "🚀  feat:     Новая функциональность" },
    { value: "fix", name: "🐛  fix:      Исправление бага" },
    { value: "docs", name: "📚  docs:     Обновление документации" },
    {
      value: "style",
      name: "💎  style:    Изменения в форматировании (пробелы, точки с запятой, оформление и т.д.)",
    },
    {
      value: "refactor",
      name: "🔨  refactor: Изменения кода без исправления багов или добавления новых возможностей",
    },
    {
      value: "perf",
      name: "⚡️  perf:     Изменения для улучшения производительности",
    },
    { value: "test", name: "🧪  test:     Добавление или изменение тестов" },
    {
      value: "chore",
      name: "📦  chore:    Обновление зависимостей, настройка инструментов (сборка, документация и т.д.)",
    },
    { value: "revert", name: "⏪  revert:   Откат изменений" },
    { value: "WIP", name: "🚧  WIP:      Работа в процессе" },
  ],

  scopes: [
    { name: "custom" },
    { name: "ui" },
    { name: "api" },
    { name: "auth" },
    { name: "db" },
    { name: "config" },
    { name: "*" },
  ],

  messages: {
    type: "📌 Выберите тип изменения:",
    scope: "🔍 Укажите область изменений (опционально):",
    customScope: "🔍 Укажите свою область изменений:",
    subject: "✏️ Краткое описание в повелительном наклонении:",
    body: '📝 Подробное описание (опционально, для переноса строк используйте "|"):',
    breaking: "💥 BREAKING CHANGES (если есть):",
    footer: "🔗 Закрытые задачи (например, #123):",
    confirmCommit:
      "✅ Вы уверены, что хотите выполнить коммит с этими данными?",
  },

  allowCustomScopes: false,
  allowBreakingChanges: ["feat", "fix"],
  subjectLimit: 120,
  breaklineChar: "|",
  footerPrefix: "Закрыто: ",
  skipQuestions: ["body", "breaking", "footer"],

  upperCaseSubject: true,
  askForBreakingChangeFirst: false,

  format: "{emoji} {type}: {subject}",
  emojiMap: {
    feat: "🚀",
    fix: "🐛",
    docs: "📚",
    style: "💎",
    refactor: "🔨",
    perf: "⚡️",
    test: "🧪",
    chore: "📦",
    revert: "⏪",
    WIP: "🚧",
  },
};
