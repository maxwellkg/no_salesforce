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
