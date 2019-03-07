class Record
  def initialize(record)
    @record = record
  end

  def id
    @record['id']
  end

  def source
    @record['source']
  end

  def title
    @record['title']
  end

  def source_link
    @record['source_link']
  end

  def full_record_link
    @record['full_record_link']
  end

  def subjects
    @record['subjects']
  end

  def locations
    @record['summary_holdings']
  end

  def authors
    @record['authors']
  end

  def publication_date
    @record['publication_date']
  end

  def content_type
    @record['content_type']
  end
end
