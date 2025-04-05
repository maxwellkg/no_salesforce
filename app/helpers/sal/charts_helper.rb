module SAL::ChartsHelper

  def prussian_blues
    %w(

      #093048
      #10545E
      #1778B5
      #269BE3
      #5DB4EA
      #93CDF1
    )
  end

  def robins_egg_blues
    %w(

      #123E40
      #1F6D6F
      #2D9B9F
      #40C5C9
      #70D3D7
      #A0E2E4
    )
  end

  def chart_blues
    [prussian_blues, robins_egg_blues].flatten
  end

  def vista_blues
    %w(
      #091B34
      #133667
      #1C519B
      #266CCF
      #538DDF
      #86AFE9
    )
  end

  def tropical_indigoes
    %w(
      #2011254
      #341D87
      #4727B9
      #6546D8
      #8F78E2
      #B9ABED
    )
  end

  def chart_purples
    [vista_blues, tropical_indigoes].flatten
  end

  def mimi_pinks
    %w(
      #5F071E
      #990B30
      #D20F43
      #F02D61
      #F4668C
      #F8A0B7
    )
  end

  def chart_reds
    [vista_blues, tropical_indigoes, mimi_pinks].flatten
  end

  def uk_blues
    %w(
      #01133D
      #012169
      #0238B6
      #024AF2
      #3571FD
      #729CFE
    )
  end

  def uk_reds
    %w(
      #5E0816
      #970C23
      #C8102E
      #EE2F4F
      #F3687F
    )
  end

  def chart_uks
    [uk_blues, uk_reds].flatten
  end

  def chart(chart_type, **chart_settings)
    chart_hsh = @presenter.chart(chart_type)

    settings =  chart_hsh[:settings]
                  .merge({ colors: chart_blues.shuffle })
                  .merge(chart_settings)

    send(chart_hsh[:method], chart_hsh[:chart_data], **settings)
  end

  def chart_without_limit(chart_type, **chart_settings)
    chart_hsh = @presenter.chart_without_limit(chart_type)

    settings =  chart_hsh[:settings]
                  .merge({ colors: chart_blues.shuffle })
                  .merge(chart_settings)

    send(chart_hsh[:method], chart_hsh[:chart_data], **settings)    
  end

  def chart_visibility_class(chart_type)
    'hidden' unless chart_type == @presenter.default_chart_type
  end

end
