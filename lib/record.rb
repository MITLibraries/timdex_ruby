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

  def contributors
    @record['contributors']
  end

  def publication_date
    @record['publication_date']
  end

  def content_type
    @record['content_type']
  end

  def content_format
    @record['content_format']
  end

  def imprint
    @record['imprint']
  end

  def isbns
    @record['isbns']
  end

  def issns
    @record['issns']
  end

  def oclcs
    @record['oclcs']
  end

  def lccn
    @record['lccn']
  end

  # full record only

  def notes
    @record['notes']
  end

  def physical_description
    @record['physical_description']
  end

  def languages
    @record['languages']
  end

  def place_of_publication
    @record['place_of_publication']
  end

  def summary
    @record['summary']
  end
end
