require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDB < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Users
  attr_accessor :fname, :lname
  attr_reader :id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM users")
    data.map { |datum| Users.new(datum) }
  end

  def self.find_by_name(f, l)

    Users.all.select  do |user|
      user.fname == f && user.lname == l
    end
  end



  def initialize(options)
   @id = options['id']
   @fname = options['fname']
   @lname = options['lname']
  end

  def authored_questions
    Questions.find_by_author_id(@id)
  end

  def authored_replies
    Replies.find_by_user_id(@id)
  end

end

class Questions
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end

  def self.find_by_author_id(author_id)
    Questions.all.select  do |question|
      question.user_id == author_id
    end
  end

  def initialize(options)
   @id = options['id']
   @title = options['title']
   @body = options['body']
   @user_id = options['user_id']
  end

  def author
    auth = Users.all.select{|user| user.id == @user_id}[0]
    auth.fname + ' ' + auth.lname
  end

  def replies
    Replies.find_by_question_id(@id)
  end
end

class Replies
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM replies")
    data.map { |datum| Replies.new(datum) }
  end

  def self.find_by_user_id(user_id)
    Replies.all.select  do |reply|
      reply.user_id == user_id
    end
  end

  def self.find_by_question_id(question_id)
    Replies.all.select  do |reply|
      reply.question_id == question_id
    end
  end

  def initialize(options)
   @id = options['id']
   @body = options['body']
   @parent_rep = options['parent_rep']
   @question_id = options['question_id']
   @user_id = options['user_id']
  end

  def author
    Users.all.select{|user| @user_id == user.id}[0]
  end

  def question
    Questions.all.select{ |question| @question_id == question.id}
  end

  def parent_reply
    Replies.all.select{|reply| @parent_rep == reply.id}
  end

  def child_replies
    Replies.all.select{ |reply| @id == reply.parent_rep }
  end

end

class Question_Likes
  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| Question_Likes.new(datum) }
  end

  def initialize(options)
   @id = options['id']
   @question_id = options['question_id']
   @user_id = options['user_id']
  end

end

class Question_Follows
  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| Question_Follows.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    #TO_IMPLEMENT
  end

  def self.followed_questions_for_user_id(user_id)

  end

  def initialize(options)
   @id = options['id']
   @question_id = options['question_id']
   @user_id = options['user_id']
  end

end
