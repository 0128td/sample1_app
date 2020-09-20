class StampsController < ApplicationController
  before_action :authenticate_user!, except: :top
  require "date"
  require "csv"

  def top
  end

  def index
    @datetime = DateTime.now
    @yymmdd = DateTime.now.to_s(:date)
    @month = @datetime.strftime("%m")
    @year = @datetime.strftime("%Y")
    @date = @year + "-" + @month
    @stamps = Stamp.where(name: current_user.name).where("date like ?", "%#{@date}%").order(date: :desc)
    @stamp = Stamp.find_by(name: current_user.name, date: @yymmdd)
  end

  def my_search
    @datetime = DateTime.now
    @month = params[:month].to_s
    @year = @datetime.strftime("%Y")
    @date = @year + "-" + @month
    @stamps = Stamp.where(name: @current_user.name).where("date like ?", "%#{@date}%")
  end

  def aggregate
    @date = Time.now.strftime("%Y-%m-%d")
    @stamps = Stamp.where(date: @date)
  end

  def day_search
    @stamps = Stamp.search(params[:date], params[:name], params[:date_from], params[:date_to]).order(:name)
    @date = params[:date]

    respond_to do |format|
      format.html
      format.csv do |csv|
        send_stamps_csv(@stamps)
      end
    end
  end

  def send_stamps_csv(stamps)
    csv_data = CSV.generate(force_quotes: true) do |csv|
      csv_column_names = [
        "名前",
        "始業時刻",
        "休憩開始時刻",
        "業務再開時刻",
        "終業時刻",
      ]
      csv << csv_column_names

      @stamps.each do |stamp|
        csv_column_values = [
          stamp.name,
          stamp.start&.strftime("%H:%M"),
          stamp.am_finish&.strftime("%H:%M"),
          stamp.pm_start&.strftime("%H:%M"),
          stamp.finish&.strftime("%H:%M"),
        ]
        csv << csv_column_values
      end
    end
    send_data(csv_data, filename: "stamps.csv")
  end

  def name_search
    @stamps = Stamp.search(params[:date], params[:name], params[:date_from], params[:date_to]).order(date: :desc)
    @name = params[:name]
    @date_from = params[:date_from]
    @date_to = params[:date_to]
  end

  def csv_export
    @stamps = Stamp.all.order(date: :desc)
    send_data render_to_string, filename: "stamp-#{Time.now.strftime("%Y%m%d%H%M%s")}.csv", type: :csv
  end

  def create_start
    @today = Time.now.to_s(:date)
    @stamp = Stamp.find_by(name: current_user.name, date: @today)
    @time = Time.now.to_s

    if @stamp.start == nil
      @stamp.update(start: @time)
      flash[:notice] = I18n.t("helpers.submit.create")
      redirect_to("/stamp/index")
    else
      flash[:notice] = I18n.t("errors.messages.taken")
      redirect_to("/stamp/index")
    end
  end

  def create_am_finish
    @today = Time.now.to_s(:date)
    @stamp = Stamp.find_by(name: current_user.name, date: @today)
    @time = Time.now.to_s

    if @stamp.start == nil
      flash[:alert] = I18n.t("errors.messages.no_start")
      redirect_to("/stamp/index")
    elsif @stamp.am_finish == nil
      @stamp.update(am_finish: @time)
      flash[:notice] = I18n.t("helpers.submit.create")
      redirect_to("/stamp/index")
    else @stamp.am_finish != nil
      flash[:alert] = I18n.t("errors.messages.taken")
      redirect_to("/stamp/index")     end
  end

  def create_pm_start
    @today = Time.now.to_s(:date)
    @stamp = Stamp.find_by(name: current_user.name, date: @today)
    @time = Time.now.to_s

    if @stamp.start == nil
      flash[:alert] = I18n.t("errors.messages.no_start")
      redirect_to("/stamp/index")
    elsif @stamp.pm_start == nil
      @stamp.update(pm_start: @time)
      flash[:notice] = I18n.t("helpers.submit.create")
      redirect_to("/stamp/index")
    else @stamp.pm_start != nil
      flash[:alert] = I18n.t("errors.messages.taken")
      redirect_to("/stamp/index")     end
  end

  def create_finish
    @today = Time.now.to_s(:date)
    @stamp = Stamp.find_by(name: current_user.name, date: @today)
    @time = Time.now.to_s

    if @stamp.start == nil
      flash[:alert] = I18n.t("errors.messages.no_start")
      redirect_to("/stamp/index")
    elsif @stamp.finish == nil
      @stamp.update(finish: @time)
      flash[:notice] = I18n.t("helpers.submit.create")
      redirect_to("/stamp/index")
    else @stamp.finish != nil
      flash[:alert] = I18n.t("errors.messages.taken")
      redirect_to("/stamp/index")     end
  end

  def create_memo
    @today = Time.now.to_s(:date)
    @stamp = Stamp.find_by(name: current_user.name, date: @today)

    if params[:memo]
      @stamp.update(memo: params[:memo])
      flash[:notice] = I18n.t("helpers.submit.create")
      redirect_to("/stamp/index")
    else
      flash[:alert] = I18n.t("errors.messages.no_entry")
      render("stamps/index")
    end
  end

  def edit
    @stamp = Stamp.find_by(token: params[:id])
    @start = @stamp.start&.strftime("%H:%M")
    @am_finish = @stamp.am_finish&.strftime("%H:%M")
    @pm_start = @stamp.pm_start&.strftime("%H:%M")
    @finish = @stamp.finish&.strftime("%H:%M")
  end

  def update
    @stamp = Stamp.find_by(id: params[:id])
    @year = @stamp.date.strftime("%Y")
    @month = @stamp.date.strftime("%m")
    @day = @stamp.date.strftime("%d")

    if params[:start] != ""
      @start = Time.parse(params[:start])
      @starth = @start.hour
      @startm = @start.min
      @u_start = Time.local(@year, @month, @day, @starth, @startm)
    end
    if params[:am_finish] != ""
      @am_finish = Time.parse(params[:am_finish])
      @am_finishh = @am_finish.hour
      @am_finishm = @am_finish.min
      @u_am_finish = Time.local(@year, @month, @day, @am_finishh, @am_finishm)
    end

    if params[:pm_start] != ""
      @pm_start = Time.parse(params[:pm_start])
      @pm_starth = @pm_start.hour
      @pm_startm = @pm_start.min
      @u_pm_start = Time.local(@year, @month, @day, @pm_starth, @pm_startm)
    end

    if params[:finish] != ""
      @finish = Time.parse(params[:finish])
      @finishh = @finish.hour
      @finishm = @finish.min
      @u_finish = Time.local(@year, @month, @day, @finishh, @finishm)
    end

    @stamp.update(
      start: @u_start,
      am_finish: @u_am_finish,
      pm_start: @u_pm_start,
      finish: @u_finish,
    )
    flash[:notice] = I18n.t("helpers.submit.update")
    redirect_to("/stamp/aggregate")
  end
end
